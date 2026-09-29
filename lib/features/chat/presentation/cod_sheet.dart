import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/dates.dart';
import '../../../core/widgets/app_bottom_sheet.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_chip.dart';
import '../domain/chat_message.dart';

/// Bottom sheet "Usulkan titik COD": lokasi (chip kampus), tanggal, jam.
/// Mengembalikan usulan, atau null bila ditutup.
Future<UsulanCod?> showUsulCodSheet(
  BuildContext context, {
  required String lokasiAwal,
  required DateTime tanggalAwal,
  required DateTime hariIni,
}) =>
    showAppBottomSheet<UsulanCod>(
      context,
      builder: (sheet) => _UsulCodSheet(
        lokasiAwal: titikKampus.contains(lokasiAwal)
            ? lokasiAwal
            : titikKampus.first,
        tanggalAwal: tanggalAwal,
        hariIni: hariIni,
      ),
    );

class _UsulCodSheet extends StatefulWidget {
  const _UsulCodSheet({
    required this.lokasiAwal,
    required this.tanggalAwal,
    required this.hariIni,
  });

  final String lokasiAwal;
  final DateTime tanggalAwal;
  final DateTime hariIni;

  @override
  State<_UsulCodSheet> createState() => _UsulCodSheetState();
}

class _UsulCodSheetState extends State<_UsulCodSheet> {
  late String _lokasi = widget.lokasiAwal;
  late DateTime _tanggal = dateOnly(widget.tanggalAwal);
  TimeOfDay _jam = const TimeOfDay(hour: 16, minute: 0);

  DateTime get _waktu =>
      _tanggal.add(Duration(hours: _jam.hour, minutes: _jam.minute));

  Future<void> _pilihTanggal() async {
    final hariIni = dateOnly(widget.hariIni);
    final d = await showDatePicker(
      context: context,
      initialDate: _tanggal.isBefore(hariIni) ? hariIni : _tanggal,
      firstDate: hariIni,
      lastDate: addDays(hariIni, 60),
      helpText: 'Tanggal COD',
    );
    if (d != null && mounted) setState(() => _tanggal = dateOnly(d));
  }

  Future<void> _pilihJam() async {
    final t = await showTimePicker(
      context: context,
      initialTime: _jam,
      helpText: 'Jam COD',
    );
    if (t != null && mounted) setState(() => _jam = t);
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AppSheetTitle('Usulkan titik COD'),
        Text('Lokasi', style: text.labelMedium),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          children: [
            for (final t in titikKampus)
              AppChip(
                key: Key('cod-lokasi-$t'),
                label: t,
                selected: _lokasi == t,
                onTap: () => setState(() => _lokasi = t),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('Waktu', style: text.labelMedium),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            AppButton(
              key: const Key('cod-tanggal'),
              label: formatTanggalPendek(_tanggal),
              icon: const Icon(Icons.event_outlined),
              compact: true,
              variant: AppButtonVariant.outline,
              onPressed: _pilihTanggal,
            ),
            AppButton(
              key: const Key('cod-jam'),
              label: formatJam(_waktu),
              icon: const Icon(Icons.schedule_rounded),
              compact: true,
              variant: AppButtonVariant.outline,
              onPressed: _pilihJam,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        AppButton(
          key: const Key('cod-kirim'),
          label: 'Kirim usulan',
          onPressed: () =>
              Navigator.pop(context, UsulanCod(lokasi: _lokasi, waktu: _waktu)),
        ),
      ],
    );
  }
}
