import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:medrive_core/medrive_core.dart';
import 'package:medrive_ui/medrive_ui.dart';

import '../../state/session.dart';
import '../../widgets/feedback.dart';
import '../../widgets/media.dart';
import '../../widgets/photo_picker.dart';
import '../report/report_providers.dart';

/// Chat pelapor ↔ driver untuk satu laporan aktif. Pesan baru masuk lewat kanal `chat.{id}`;
/// bila WebSocket putus, halaman terbaru di-poll tiap 10 detik.
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key, required this.reportId});

  final int reportId;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  static const _maxLength = 1000;

  final _input = TextEditingController();
  final _messages = <ChatMessage>[];
  Object? _error;
  bool _loading = true;
  bool _loadingOlder = false;
  bool _hasMore = false;
  int? _nextBeforeId;
  bool _isOpen = true;
  bool _sending = false;
  int? _firstUnreadId;

  RealtimeSubscription? _chatChannel;
  RealtimeSubscription? _reportChannel;
  Timer? _poll;
  Timer? _markRead;

  ChatRepository get _chat => ref.read(chatRepositoryProvider);

  int? get _myId => ref.read(sessionProvider).user?.id;

  @override
  void initState() {
    super.initState();
    _input.addListener(() => setState(() {}));
    unawaited(_loadLatest(initial: true));
    unawaited(_subscribe());
    _poll = Timer.periodic(const Duration(seconds: 10), (_) {
      if (_isOpen && !ref.read(realtimeServiceProvider).isConnected) {
        unawaited(_loadLatest());
      }
    });
  }

  @override
  void dispose() {
    _poll?.cancel();
    _markRead?.cancel();
    _chatChannel?.cancel();
    _reportChannel?.cancel();
    _input.dispose();
    super.dispose();
  }

  bool _isMine(ChatMessage message) => message.isMine ?? message.senderId == _myId;

  Future<void> _subscribe() async {
    final realtime = ref.read(realtimeServiceProvider);
    final id = widget.reportId;
    try {
      final chatChannel = await realtime.subscribe('chat.$id', {
        'ChatMessageSent': (data) {
          try {
            _merge([ChatMessage.fromJson(data)]);
          } on Object {
            // Payload tidak lengkap; pesan tetap muncul pada pemuatan berikutnya.
          }
        },
        'ChatMessageRead': _onRead,
      });
      final reportChannel = await realtime.subscribe('report.$id', {
        'ReportStatusChanged': (data) {
          final status = data['status'];
          if (status is String && ReportStatus.isClosed(status) && mounted) {
            setState(() => _isOpen = false);
            ref.invalidate(reportDetailProvider(id));
          }
        },
      });
      if (!mounted) {
        chatChannel.cancel();
        reportChannel.cancel();
        return;
      }
      _chatChannel = chatChannel;
      _reportChannel = reportChannel;
    } on Object {
      // Polling cadangan tetap berjalan.
    }
  }

  void _onRead(Map<String, dynamic> data) {
    final readerId = (data['reader_id'] as num?)?.toInt();
    final lastReadId = (data['last_read_id'] as num?)?.toInt();
    if (readerId == null || lastReadId == null || readerId == _myId || !mounted) {
      return;
    }
    final readAt = DateTime.tryParse('${data['read_at']}') ?? DateTime.now();
    setState(() {
      for (var index = 0; index < _messages.length; index++) {
        final message = _messages[index];
        if (_isMine(message) && message.readAt == null && message.id <= lastReadId) {
          _messages[index] = message.copyWith(readAt: readAt);
        }
      }
    });
  }

  Future<void> _loadLatest({bool initial = false}) async {
    try {
      final page = await _chat.history(widget.reportId);
      if (!mounted) {
        return;
      }
      if (initial) {
        _firstUnreadId = page.messages.where((message) => !_isMine(message) && message.readAt == null).firstOrNull?.id;
        _hasMore = page.hasMore;
        _nextBeforeId = page.nextBeforeId;
      }
      _isOpen = page.isOpen;
      _merge(page.messages);
      setState(() {
        _loading = false;
        _error = null;
      });
    } on ApiError catch (error) {
      if (mounted && initial) {
        setState(() {
          _loading = false;
          _error = error;
        });
      }
    }
  }

  Future<void> _loadOlder() async {
    if (_loadingOlder || !_hasMore || _nextBeforeId == null) {
      return;
    }
    setState(() => _loadingOlder = true);
    try {
      final page = await _chat.history(widget.reportId, beforeId: _nextBeforeId);
      if (!mounted) {
        return;
      }
      _hasMore = page.hasMore;
      _nextBeforeId = page.nextBeforeId;
      _merge(page.messages);
    } on ApiError catch (error) {
      if (mounted) {
        showError(context, error);
      }
    } finally {
      if (mounted) {
        setState(() => _loadingOlder = false);
      }
    }
  }

  /// Gabungkan pesan (tanpa duplikat, urut id) dan tandai dibaca bila ada pesan driver yang baru.
  void _merge(List<ChatMessage> incoming) {
    if (!mounted) {
      return;
    }
    final byId = {for (final message in _messages) message.id: message};
    var hasNewFromDriver = false;
    for (final message in incoming) {
      final existing = byId[message.id];
      if (existing == null && !_isMine(message) && message.readAt == null) {
        hasNewFromDriver = true;
      }
      byId[message.id] = existing == null ? message : message.copyWith(isMine: message.isMine ?? existing.isMine);
    }
    setState(() {
      _messages
        ..clear()
        ..addAll(byId.values.toList()..sort((a, b) => a.id.compareTo(b.id)));
    });
    if (hasNewFromDriver) {
      _scheduleMarkRead();
    }
  }

  void _scheduleMarkRead() {
    _markRead?.cancel();
    _markRead = Timer(const Duration(milliseconds: 600), () {
      unawaited(_chat.markRead(widget.reportId).then<void>((_) {}, onError: (_) {}));
    });
  }

  Future<void> _sendText() async {
    final text = _input.text.trim();
    if (text.isEmpty || _sending) {
      return;
    }
    setState(() => _sending = true);
    try {
      final message = await _chat.sendText(widget.reportId, text);
      _input.clear();
      _merge([message]);
    } on ApiError catch (error) {
      if (mounted) {
        _handleSendError(error);
      }
    } finally {
      if (mounted) {
        setState(() => _sending = false);
      }
    }
  }

  Future<void> _sendImage() async {
    if (_sending) {
      return;
    }
    final path = await ref.read(photoPickerProvider).pick(context);
    if (path == null || !mounted) {
      return;
    }
    setState(() => _sending = true);
    try {
      _merge([await _chat.sendImage(widget.reportId, path)]);
    } on ApiError catch (error) {
      if (mounted) {
        _handleSendError(error);
      }
    } finally {
      if (mounted) {
        setState(() => _sending = false);
      }
    }
  }

  void _handleSendError(ApiError error) {
    if (error.code == 'chat_closed') {
      setState(() => _isOpen = false);
    }
    showError(context, error);
  }

  @override
  Widget build(BuildContext context) {
    final report = ref.watch(reportDetailProvider(widget.reportId)).value;
    final driver = report?.driver;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            if (driver != null) ...[
              DriverAvatar(name: driver.name, photoUrl: driver.photoUrl, size: 38),
              const SizedBox(width: MedSpace.md),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(driver?.name ?? 'Chat Driver', maxLines: 1, overflow: TextOverflow.ellipsis),
                  if (report != null)
                    Text(
                      [report.code, report.ambulance?.plateNumber].whereType<String>().join(' · '),
                      style: const TextStyle(fontSize: 12.5, color: MedColors.inkMuted, fontWeight: FontWeight.w700),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessages()),
          if (_isOpen) _buildComposer() else const _ClosedBanner(),
        ],
      ),
    );
  }

  Widget _buildMessages() {
    if (_loading) {
      return const _ChatSkeleton();
    }
    if (_error != null) {
      return AsyncErrorView(
        error: _error!,
        onRetry: () {
          setState(() {
            _loading = true;
            _error = null;
          });
          unawaited(_loadLatest(initial: true));
        },
      );
    }
    if (_messages.isEmpty) {
      return const EmptyState(
        icon: Icons.forum_outlined,
        title: 'Belum ada pesan',
        message: 'Kirim patokan lokasi atau kondisi terbaru pasien agar driver lebih cepat menemukan Anda.',
      );
    }

    final items = _messages.reversed.toList();
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.extentAfter < 240) {
          unawaited(_loadOlder());
        }
        return false;
      },
      child: ListView.builder(
        reverse: true,
        padding: const EdgeInsets.fromLTRB(MedSpace.md, MedSpace.md, MedSpace.md, MedSpace.md),
        itemCount: items.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == items.length) {
            return const Padding(
              padding: EdgeInsets.all(MedSpace.md),
              child: Center(child: SizedBox.square(dimension: 24, child: CircularProgressIndicator(strokeWidth: 2.5))),
            );
          }
          final message = items[index];
          final older = index + 1 < items.length ? items[index + 1] : null;
          final newDay = older == null || !_sameDay(older.createdAt, message.createdAt);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (newDay) _DayDivider(date: message.createdAt),
              if (message.id == _firstUnreadId) const _UnreadDivider(),
              _Bubble(message: message, mine: _isMine(message)),
            ],
          );
        },
      ),
    );
  }

  static bool _sameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) {
      return true;
    }
    final x = a.toLocal();
    final y = b.toLocal();
    return x.year == y.year && x.month == y.month && x.day == y.day;
  }

  Widget _buildComposer() {
    final canSend = _input.text.trim().isNotEmpty && !_sending;

    return Material(
      color: MedColors.surface,
      elevation: 8,
      shadowColor: Colors.black26,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(MedSpace.sm, MedSpace.sm, MedSpace.sm, MedSpace.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                tooltip: 'Kirim foto',
                onPressed: _sending ? null : _sendImage,
                icon: const Icon(Icons.photo_camera_rounded, color: MedColors.inkMuted),
              ),
              Expanded(
                child: TextField(
                  controller: _input,
                  minLines: 1,
                  maxLines: 4,
                  maxLength: _maxLength,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(hintText: 'Tulis pesan…', counterText: ''),
                ),
              ),
              const SizedBox(width: MedSpace.xs),
              IconButton.filled(
                tooltip: 'Kirim',
                onPressed: canSend ? _sendText : null,
                icon: _sending
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                      )
                    : const Icon(Icons.send_rounded),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message, required this.mine});

  final ChatMessage message;
  final bool mine;

  @override
  Widget build(BuildContext context) {
    final foreground = mine ? Colors.white : MedColors.ink;
    final radius = BorderRadius.only(
      topLeft: const Radius.circular(18),
      topRight: const Radius.circular(18),
      bottomLeft: Radius.circular(mine ? 18 : 4),
      bottomRight: Radius.circular(mine ? 4 : 18),
    );
    final imageUrl = message.imageUrl;

    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.76),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 3),
          padding: message.isImage ? const EdgeInsets.all(4) : const EdgeInsets.fromLTRB(14, 10, 14, 8),
          decoration: BoxDecoration(color: mine ? MedColors.brandDeep : MedColors.field, borderRadius: radius),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (message.isImage && imageUrl != null)
                GestureDetector(
                  onTap: () => showImageViewer(context, imageUrl, caption: message.senderName),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Semantics(
                      label: 'Foto dari ${mine ? 'Anda' : message.senderName ?? 'driver'}, ketuk untuk memperbesar',
                      button: true,
                      child: AuthImage(url: imageUrl, width: 220, height: 220),
                    ),
                  ),
                )
              else
                Align(
                  alignment: Alignment.centerLeft,
                  widthFactor: 1,
                  child: Text(message.body ?? '', style: TextStyle(color: foreground, fontSize: 15.5, height: 1.35)),
                ),
              Padding(
                padding: message.isImage ? const EdgeInsets.fromLTRB(8, 4, 8, 2) : const EdgeInsets.only(top: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      formatTime(message.createdAt),
                      style: TextStyle(color: mine ? Colors.white : MedColors.inkMuted, fontSize: 11.5),
                    ),
                    if (mine) ...[
                      const SizedBox(width: 4),
                      Icon(
                        message.readAt == null ? Icons.done_rounded : Icons.done_all_rounded,
                        size: 15,
                        color: Colors.white,
                        semanticLabel: message.readAt == null ? 'Terkirim' : 'Dibaca',
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DayDivider extends StatelessWidget {
  const _DayDivider({required this.date});

  final DateTime? date;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: MedSpace.md),
        child: Center(
          child: Text(formatDay(date), style: const TextStyle(color: MedColors.inkMuted, fontWeight: FontWeight.w700, fontSize: 12.5)),
        ),
      );
}

class _UnreadDivider extends StatelessWidget {
  const _UnreadDivider();

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.symmetric(vertical: MedSpace.sm),
        child: Row(
          children: [
            Expanded(child: Divider(color: MedColors.brand)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: MedSpace.sm),
              child: Text('Pesan baru', style: TextStyle(color: MedColors.brandDeep, fontWeight: FontWeight.w800, fontSize: 12.5)),
            ),
            Expanded(child: Divider(color: MedColors.brand)),
          ],
        ),
      );
}

class _ClosedBanner extends StatelessWidget {
  const _ClosedBanner();

  @override
  Widget build(BuildContext context) => const ColoredBox(
        color: MedColors.field,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.all(MedSpace.lg),
            child: Row(
              children: [
                Icon(Icons.lock_outline_rounded, color: MedColors.inkMuted),
                SizedBox(width: MedSpace.md),
                Expanded(
                  child: Text(
                    'Chat ditutup karena laporan sudah selesai. Riwayat pesan tetap bisa dibaca.',
                    style: TextStyle(color: MedColors.inkMuted, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

class _ChatSkeleton extends StatelessWidget {
  const _ChatSkeleton();

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(MedSpace.lg),
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          Align(alignment: Alignment.centerLeft, child: Skeleton(width: 200, height: 44, radius: 18)),
          SizedBox(height: MedSpace.sm),
          Align(alignment: Alignment.centerRight, child: Skeleton(width: 160, height: 44, radius: 18)),
          SizedBox(height: MedSpace.sm),
          Align(alignment: Alignment.centerLeft, child: Skeleton(width: 240, height: 64, radius: 18)),
          SizedBox(height: MedSpace.sm),
          Align(alignment: Alignment.centerRight, child: Skeleton(width: 120, height: 44, radius: 18)),
        ],
      );
}
