import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../utils/dates.dart';

/// Rentang tanggal yang sedang dipilih (tanpa jam). `end == null` = baru mulai.
@immutable
class DateSelection {
  const DateSelection({this.start, this.end});

  static const empty = DateSelection();

  final DateTime? start;
  final DateTime? end;

  bool get isComplete => start != null && end != null;

  @override
  bool operator ==(Object other) =>
      other is DateSelection && other.start == start && other.end == end;

  @override
  int get hashCode => Object.hash(start, end);
}

/// Tap pertama = mulai, tap kedua = kembali; kalau tap kedua lebih awal,
/// urutannya ditukar. Tap berikutnya memulai rentang baru.
DateSelection nextSelection(DateSelection current, DateTime tapped) {
  final day = dateOnly(tapped);
  final start = current.start;
  if (start == null || current.end != null) return DateSelection(start: day);
  return daysBetween(start, day) < 0
      ? DateSelection(start: day, end: start)
      : DateSelection(start: start, end: day);
}

/// Kalender ketersediaan (7 kolom mulai Senin). Tanggal lampau & terblokir
/// redup + dicoret dan tidak bisa ditekan. Rentang yang ditolak [validateRange]
/// tidak diterima; pesannya tampil inline di bawah grid.
class AvailabilityCalendar extends StatefulWidget {
  const AvailabilityCalendar({
    super.key,
    required this.today,
    required this.selection,
    required this.onChanged,
    required this.isBlocked,
    required this.validateRange,
    this.maxMonthsAhead = 3,
  });

  final DateTime today;
  final DateSelection selection;
  final ValueChanged<DateSelection> onChanged;
  final bool Function(DateTime day) isBlocked;

  /// Pesan error untuk rentang lengkap, atau `null` bila boleh.
  final String? Function(DateTime start, DateTime end) validateRange;
  final int maxMonthsAhead;

  @override
  State<AvailabilityCalendar> createState() => _AvailabilityCalendarState();
}

class _AvailabilityCalendarState extends State<AvailabilityCalendar> {
  late DateTime _month = DateTime(widget.today.year, widget.today.month);
  String? _error;

  int get _monthOffset =>
      (_month.year - widget.today.year) * 12 + _month.month - widget.today.month;

  bool _disabled(DateTime day) =>
      daysBetween(widget.today, day) < 0 || widget.isBlocked(day);

  void _goMonth(int delta) =>
      setState(() => _month = DateTime(_month.year, _month.month + delta));

  void _tap(DateTime day) {
    final next = nextSelection(widget.selection, day);
    if (next.isComplete) {
      final error = widget.validateRange(next.start!, next.end!);
      if (error != null) {
        setState(() => _error = error);
        widget.onChanged(DateSelection(start: widget.selection.start));
        return;
      }
    }
    setState(() => _error = null);
    widget.onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(
                    header: true,
                    liveRegion: true,
                    child: Text(
                      'Pilih tanggal · ${formatBulan(_month)}',
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                  Text(
                    'Coret = sudah disewa',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Bulan sebelumnya',
              onPressed: _monthOffset > 0 ? () => _goMonth(-1) : null,
              icon: const Icon(Icons.chevron_left_rounded),
            ),
            IconButton(
              tooltip: 'Bulan berikutnya',
              onPressed: _monthOffset < widget.maxMonthsAhead
                  ? () => _goMonth(1)
                  : null,
              icon: const Icon(Icons.chevron_right_rounded),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        MediaQuery.withClampedTextScaling(
          maxScaleFactor: 1.4,
          child: Column(
            children: [
              ExcludeSemantics(
                child: Row(
                  children: [
                    for (final h in namaHariPendek())
                      Expanded(
                        child: Text(
                          h,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.labelSmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              ..._weeks(),
            ],
          ),
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.md),
            child: Semantics(
              liveRegion: true,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.error_outline_rounded,
                      size: AppSizes.iconXs, color: scheme.error),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      _error!,
                      key: const Key('calendar-error'),
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: scheme.error),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  List<Widget> _weeks() {
    final first = _month;
    final leading = first.weekday - 1; // Senin = 0
    final daysInMonth = DateTime(first.year, first.month + 1, 0).day;
    final cells = [
      for (var i = 0; i < leading; i++) null,
      for (var d = 1; d <= daysInMonth; d++) DateTime(first.year, first.month, d),
    ];
    while (cells.length % 7 != 0) {
      cells.add(null);
    }
    return [
      for (var w = 0; w < cells.length; w += 7)
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.xs),
          child: Row(
            children: [
              for (final day in cells.sublist(w, w + 7))
                Expanded(
                  child: day == null
                      ? const SizedBox(height: AppSizes.calendarCell)
                      : _DayCell(
                          day: day,
                          today: widget.today,
                          disabled: _disabled(day),
                          blocked: widget.isBlocked(day),
                          selection: widget.selection,
                          onTap: () => _tap(day),
                        ),
                ),
            ],
          ),
        ),
    ];
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.today,
    required this.disabled,
    required this.blocked,
    required this.selection,
    required this.onTap,
  });

  final DateTime day;
  final DateTime today;
  final bool disabled;
  final bool blocked;
  final DateSelection selection;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final colors = AppColors.of(context);

    final start = selection.start;
    final end = selection.end;
    final isStart = start != null && isSameDay(day, start);
    final isEnd = end != null && isSameDay(day, end);
    final isEdge = isStart || isEnd;
    final inRange = start != null &&
        end != null &&
        daysBetween(start, day) > 0 &&
        daysBetween(day, end) > 0;
    final isToday = isSameDay(day, today);

    final (Color? bg, Color fg) = switch ((isEdge, inRange, disabled)) {
      (true, _, _) => (scheme.primary, scheme.onPrimary),
      (_, true, _) => (colors.accentSoft, colors.accentText),
      (_, _, true) => (null, scheme.onSurfaceVariant.withValues(alpha: 0.45)),
      _ => (null, scheme.onSurface),
    };

    final state = [
      if (blocked) 'sudah disewa' else if (disabled) 'sudah lewat',
      if (isStart && isEnd) 'tanggal ambil dan kembali'
      else if (isStart) 'tanggal ambil'
      else if (isEnd) 'tanggal kembali'
      else if (inRange) 'dalam rentang',
      if (isToday) 'hari ini',
    ].join(', ');

    return Semantics(
      button: !disabled,
      enabled: !disabled,
      selected: isEdge || inRange,
      label: '${formatTanggalPanjang(day)}${state.isEmpty ? '' : ', $state'}',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs / 2),
        child: Material(
          color: bg ?? Colors.transparent,
          borderRadius:
              const BorderRadius.all(Radius.circular(AppRadius.calendarCell)),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            key: Key('day-${day.year}-${day.month}-${day.day}'),
            onTap: disabled ? null : onTap,
            child: SizedBox(
              height: AppSizes.calendarCell,
              child: Center(
                child: Text(
                  '${day.day}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                        color: fg,
                        fontWeight: isEdge || isToday || inRange
                            ? FontWeight.w800
                            : FontWeight.w500,
                        decoration:
                            disabled ? TextDecoration.lineThrough : null,
                        decorationColor: fg,
                      ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
