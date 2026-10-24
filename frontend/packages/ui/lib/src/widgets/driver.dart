import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../format.dart';
import '../tokens.dart';
import 'cards.dart';

/// Satu langkah [StatusStepper]: kode status (untuk warna semantik) + label.
class StatusStep {
  const StatusStep(this.status, this.label);

  final String status;
  final String label;
}

/// Urutan status misi driver. Langkah selesai bertanda centang hijau, langkah berjalan memakai
/// warna status semantik yang sama dengan badge, langkah berikutnya abu bergaris.
class StatusStepper extends StatelessWidget {
  const StatusStepper({super.key, required this.steps, required this.current});

  final List<StatusStep> steps;

  /// Kode status saat ini. Status di luar daftar (mis. `selesai` saat daftar tanpa selesai)
  /// dianggap melewati semua langkah.
  final String current;

  @override
  Widget build(BuildContext context) {
    var currentIndex = steps.indexWhere((step) => step.status == current);
    if (currentIndex < 0) {
      currentIndex = steps.length;
    }

    return Semantics(
      label: currentIndex < steps.length
          ? 'Langkah ${currentIndex + 1} dari ${steps.length}: ${steps[currentIndex].label}'
          : 'Semua langkah selesai',
      child: ExcludeSemantics(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var index = 0; index < steps.length; index++)
              Expanded(
                child: _StepCell(
                  step: steps[index],
                  number: index + 1,
                  done: index < currentIndex,
                  active: index == currentIndex,
                  first: index == 0,
                  last: index == steps.length - 1,
                  lineDone: index <= currentIndex,
                  nextLineDone: index < currentIndex,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StepCell extends StatelessWidget {
  const _StepCell({
    required this.step,
    required this.number,
    required this.done,
    required this.active,
    required this.first,
    required this.last,
    required this.lineDone,
    required this.nextLineDone,
  });

  final StatusStep step;
  final int number;
  final bool done;
  final bool active;
  final bool first;
  final bool last;
  final bool lineDone;
  final bool nextLineDone;

  @override
  Widget build(BuildContext context) {
    final tone = StatusTone.of(step.status);
    final Color fill = done ? MedColors.success : (active ? tone.foreground : MedColors.surface);
    final Color border = done ? MedColors.success : (active ? tone.foreground : MedColors.line);

    Widget line(bool visible, bool complete) => Expanded(
          child: Container(height: 3, color: visible ? (complete ? MedColors.success : MedColors.line) : Colors.transparent),
        );

    return Column(
      children: [
        SizedBox(
          height: 30,
          child: Row(
            children: [
              line(!first, lineDone),
              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: fill, shape: BoxShape.circle, border: Border.all(color: border, width: 2)),
                child: done
                    ? const Icon(Icons.check_rounded, size: 18, color: Colors.white)
                    : Text(
                        '$number',
                        style: TextStyle(
                          color: active ? Colors.white : MedColors.inkFaint,
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                        ),
                      ),
              ),
              line(!last, nextLineDone),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Text(
            step.label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11.5,
              height: 1.2,
              fontWeight: active ? FontWeight.w900 : FontWeight.w700,
              color: active ? tone.foreground : (done ? MedColors.ink : MedColors.inkMuted),
            ),
          ),
        ),
      ],
    );
  }
}

/// Kartu shift aktif: ambulans yang dipakai (nopol dari API), jam mulai, durasi berjalan, serta
/// indikator GPS dan baterai. Durasi diperbarui tiap 30 detik.
class ShiftStatusCard extends StatefulWidget {
  const ShiftStatusCard({
    super.key,
    required this.plateNumber,
    required this.startedAt,
    this.vehicleName,
    this.ambulanceType,
    this.gpsActive = false,
    this.gpsLabel,
    this.batteryLevel,
    this.trailing,
  });

  final String plateNumber;
  final String? vehicleName;
  final String? ambulanceType;
  final DateTime? startedAt;
  final bool gpsActive;

  /// Keterangan GPS, mis. "Terkirim 10.15" atau "Mencari sinyal".
  final String? gpsLabel;
  final int? batteryLevel;
  final Widget? trailing;

  @override
  State<ShiftStatusCard> createState() => _ShiftStatusCardState();
}

class _ShiftStatusCardState extends State<ShiftStatusCard> {
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    _tick = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final startedAt = widget.startedAt;
    final elapsed = startedAt == null ? null : DateTime.now().difference(startedAt);
    final subtitle = [widget.vehicleName, widget.ambulanceType].whereType<String>().where((part) => part.isNotEmpty).join(' · ');
    final battery = widget.batteryLevel;
    final lowBattery = battery != null && battery < 20;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const ReportTypeTile(icon: Icons.airport_shuttle_rounded, size: 46),
              const SizedBox(width: MedSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.plateNumber,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 0.6, color: MedColors.ink),
                    ),
                    if (subtitle.isNotEmpty)
                      Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: MedColors.inkMuted)),
                  ],
                ),
              ),
              ?widget.trailing,
            ],
          ),
          const SizedBox(height: MedSpace.md),
          const Divider(),
          const SizedBox(height: MedSpace.md),
          Row(
            children: [
              Expanded(child: _Metric(label: 'Mulai shift', value: formatTime(startedAt))),
              Expanded(child: _Metric(label: 'Durasi', value: elapsed == null ? '-' : _formatElapsed(elapsed))),
            ],
          ),
          const SizedBox(height: MedSpace.md),
          Wrap(
            spacing: MedSpace.sm,
            runSpacing: MedSpace.sm,
            children: [
              _Indicator(
                icon: widget.gpsActive ? Icons.gps_fixed_rounded : Icons.gps_not_fixed_rounded,
                label: widget.gpsLabel ?? (widget.gpsActive ? 'GPS aktif' : 'Mencari sinyal GPS'),
                color: widget.gpsActive ? MedColors.success : MedColors.warning,
              ),
              if (battery != null)
                _Indicator(
                  icon: lowBattery ? Icons.battery_alert_rounded : Icons.battery_std_rounded,
                  label: 'Baterai $battery%',
                  color: lowBattery ? MedColors.brandDeep : MedColors.inkMuted,
                ),
            ],
          ),
        ],
      ),
    );
  }

  static String _formatElapsed(Duration elapsed) {
    final hours = elapsed.inHours;
    final minutes = elapsed.inMinutes % 60;
    if (hours == 0) {
      return '$minutes menit';
    }
    return '$hours j $minutes m';
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: MedColors.inkMuted, fontSize: 12.5, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(color: MedColors.ink, fontSize: 18, fontWeight: FontWeight.w900)),
        ],
      );
}

class _Indicator extends StatelessWidget {
  const _Indicator({required this.icon, required this.label, required this.color});

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(color: MedColors.field, borderRadius: BorderRadius.circular(MedRadius.sm)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(color: MedColors.ink, fontWeight: FontWeight.w700, fontSize: 13)),
          ],
        ),
      );
}

/// Label prioritas jenis laporan (`report_types.priority`: 1 paling mendesak).
String priorityLabel(int? priority) => switch (priority) {
      1 => 'Prioritas 1 · Kritis',
      2 => 'Prioritas 2 · Mendesak',
      3 => 'Prioritas 3',
      null => 'Prioritas -',
      _ => 'Prioritas $priority · Terjadwal',
    };

/// Kartu tawaran laporan yang menunggu jawaban (daftar cadangan di beranda driver). Warna dan
/// ikon jenis laporan berasal dari database.
class DispatchOfferCard extends StatelessWidget {
  const DispatchOfferCard({
    super.key,
    required this.typeName,
    required this.typeColor,
    required this.typeIcon,
    required this.distanceKm,
    required this.onTap,
    this.code,
    this.address,
    this.priority,
  });

  final String typeName;
  final Color typeColor;
  final IconData typeIcon;
  final String? code;
  final double distanceKm;
  final String? address;
  final int? priority;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: 'Tawaran $typeName, ${formatDistance(distanceKm)}. Buka untuk menjawab',
        child: AppCard(
          onTap: onTap,
          child: ExcludeSemantics(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ReportTypeTile(icon: typeIcon, color: typeColor, size: 48),
                const SizedBox(width: MedSpace.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(typeName, style: Theme.of(context).textTheme.titleMedium),
                      Text(
                        [code, priorityLabel(priority)].whereType<String>().join(' · '),
                        style: const TextStyle(color: MedColors.inkMuted, fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      if (address != null) ...[
                        const SizedBox(height: 4),
                        Text(address!, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: MedSpace.sm),
                Text(
                  formatDistance(distanceKm),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: MedColors.ink),
                ),
              ],
            ),
          ),
        ),
      );
}
