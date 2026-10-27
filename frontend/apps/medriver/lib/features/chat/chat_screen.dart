import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:medrive_core/medrive_core.dart';
import 'package:medrive_ui/medrive_ui.dart';

import '../../state/session.dart';
import '../../widgets/feedback.dart';
import '../../widgets/media.dart';
import '../../widgets/photo_picker.dart';
import 'chat_providers.dart';

/// Chat driver ↔ pelapor untuk satu laporan (komponen chat bersama `medrive_ui`, sama dengan
/// aplikasi pelapor). Pesan baru masuk lewat kanal `chat.{id}`; bila WebSocket putus atau kanal
/// ditolak, halaman terbaru di-poll tiap 10 detik. Status tertutup dibaca dari `meta.is_open`
/// karena kanal `report.{id}` hanya untuk pelapor.
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
  bool _channelRejected = false;
  Timer? _poll;
  Timer? _markRead;

  ChatRepository get _chat => ref.read(chatRepositoryProvider);

  int? get _myId => ref.read(sessionProvider).user?.id;

  @override
  void initState() {
    super.initState();
    unawaited(_loadLatest(initial: true));
    unawaited(_subscribe());
    _poll = Timer.periodic(const Duration(seconds: 10), (_) {
      if (_isOpen && (_channelRejected || !ref.read(realtimeServiceProvider).isConnected)) {
        unawaited(_loadLatest());
      }
    });
  }

  @override
  void dispose() {
    _poll?.cancel();
    _markRead?.cancel();
    _chatChannel?.cancel();
    _input.dispose();
    super.dispose();
  }

  bool _isMine(ChatMessage message) => message.isMine ?? message.senderId == _myId;

  Future<void> _subscribe() async {
    final realtime = ref.read(realtimeServiceProvider);
    final id = widget.reportId;
    try {
      final chatChannel = await realtime.subscribe(
        'chat.$id',
        {
          'ChatMessageSent': (data) {
            try {
              _merge([ChatMessage.fromJson(data)]);
            } on Object {
              // Payload tidak lengkap; pesan tetap muncul pada pemuatan berikutnya.
            }
          },
          'ChatMessageRead': _onRead,
        },
        onAuthFailed: () => _channelRejected = true,
      );
      if (!mounted) {
        chatChannel.cancel();
        return;
      }
      _chatChannel = chatChannel;
    } on Object {
      // Polling cadangan tetap berjalan.
      _channelRejected = true;
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

  /// Gabungkan pesan (tanpa duplikat, urut id) dan tandai dibaca bila ada pesan pelapor yang baru.
  void _merge(List<ChatMessage> incoming) {
    if (!mounted) {
      return;
    }
    final byId = {for (final message in _messages) message.id: message};
    var hasNewFromPeer = false;
    for (final message in incoming) {
      final existing = byId[message.id];
      if (existing == null && !_isMine(message) && message.readAt == null) {
        hasNewFromPeer = true;
      }
      byId[message.id] = existing == null ? message : message.copyWith(isMine: message.isMine ?? existing.isMine);
    }
    setState(() {
      _messages
        ..clear()
        ..addAll(byId.values.toList()..sort((a, b) => a.id.compareTo(b.id)));
    });
    if (hasNewFromPeer) {
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
    final report = ref.watch(chatReportProvider(widget.reportId)).value;
    final reporter = report?.reporter;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            if (reporter != null) ...[
              InitialsAvatar(name: reporter.name, size: 38),
              const SizedBox(width: MedSpace.md),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(reporter?.name ?? 'Chat Pelapor', maxLines: 1, overflow: TextOverflow.ellipsis),
                  if (report != null)
                    Text(
                      '${report.code} · ${report.typeName}',
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
          if (_isOpen)
            _buildComposer()
          else
            const ChatClosedBanner(message: 'Chat ditutup karena laporan sudah tidak aktif. Riwayat pesan tetap bisa dibaca.'),
        ],
      ),
    );
  }

  Widget _buildMessages() {
    if (_loading) {
      return const ChatSkeleton();
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
        message: 'Kabari pelapor posisi ambulans, atau minta patokan lokasi dan kondisi terbaru pasien.',
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
              if (newDay) ChatDayDivider(date: message.createdAt),
              if (message.id == _firstUnreadId) const ChatUnreadDivider(),
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

  Widget _buildComposer() => ChatComposer(
        controller: _input,
        sending: _sending,
        maxLength: _maxLength,
        onSend: _sendText,
        onPickImage: _sendImage,
      );
}

/// Gelembung pesan: komponen bersama [ChatBubble] + gambar privat ber-token.
class _Bubble extends StatelessWidget {
  const _Bubble({required this.message, required this.mine});

  final ChatMessage message;
  final bool mine;

  @override
  Widget build(BuildContext context) {
    final imageUrl = message.imageUrl;
    final hasImage = message.isImage && imageUrl != null;

    return ChatBubble(
      mine: mine,
      body: message.body,
      sentAt: message.createdAt,
      read: message.readAt != null,
      image: hasImage ? AuthImage(url: imageUrl, width: 220, height: 220) : null,
      imageLabel: hasImage ? 'Foto dari ${mine ? 'Anda' : message.senderName ?? 'pelapor'}, ketuk untuk memperbesar' : null,
      onImageTap: hasImage ? () => showImageViewer(context, imageUrl, caption: message.senderName) : null,
    );
  }
}
