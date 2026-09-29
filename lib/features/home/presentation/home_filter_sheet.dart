import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_bottom_sheet.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_chip.dart';
import '../../item/domain/item_filter.dart';

typedef HomeFilterResult = ({
  ItemSort sort,
  int? hargaMaks,
  bool hanyaTersedia,
  bool hanyaBarter,
});

const _defaults = (
  sort: ItemSort.terpopuler,
  hargaMaks: null,
  hanyaTersedia: false,
  hanyaBarter: false,
);

Future<HomeFilterResult?> showHomeFilterSheet(
  BuildContext context,
  ItemFilter current,
) =>
    showAppBottomSheet<HomeFilterResult>(
      context,
      builder: (_) => _FilterSheet(current),
    );

class _FilterSheet extends StatefulWidget {
  const _FilterSheet(this.initial);

  final ItemFilter initial;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late ItemSort _sort = widget.initial.sort;
  late double _harga =
      (widget.initial.hargaMaks ?? HargaFilter.max).toDouble();
  late bool _hanyaTersedia = widget.initial.hanyaTersedia;
  late bool _hanyaBarter = widget.initial.hanyaBarter;

  bool get _noLimit => _harga >= HargaFilter.max;

  String get _hargaLabel => _noLimit ? 'Semua harga' : formatRupiah(_harga.round());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = theme.textTheme;
    final colors = AppColors.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AppSheetTitle('Filter'),
        const SizedBox(height: AppSpacing.sm),
        Text('Urutkan', style: text.titleMedium),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final s in ItemSort.values)
              AppChip(
                label: s.label,
                selected: s == _sort,
                onTap: () => setState(() => _sort = s),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        Row(
          children: [
            Expanded(
              child: Text('Harga maksimal per hari', style: text.titleMedium),
            ),
            Text(
              _hargaLabel,
              style: text.labelMedium?.copyWith(
                color: colors.accentText,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        Slider(
          value: _harga,
          min: HargaFilter.min.toDouble(),
          max: HargaFilter.max.toDouble(),
          divisions: (HargaFilter.max - HargaFilter.min) ~/ HargaFilter.step,
          label: _hargaLabel,
          semanticFormatterCallback: (_) => _hargaLabel,
          onChanged: (v) => setState(() => _harga = v),
        ),
        MergeSemantics(
          child: InkWell(
            borderRadius: AppRadius.inputAll,
            onTap: () => setState(() => _hanyaTersedia = !_hanyaTersedia),
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(minHeight: AppSizes.minTapTarget),
              child: Row(
                children: [
                  Expanded(
                    child: Text('Hanya yang tersedia', style: text.titleMedium),
                  ),
                  Switch(
                    value: _hanyaTersedia,
                    onChanged: (v) => setState(() => _hanyaTersedia = v),
                  ),
                ],
              ),
            ),
          ),
        ),
        MergeSemantics(
          child: InkWell(
            key: const Key('filter-barter'),
            borderRadius: AppRadius.inputAll,
            onTap: () => setState(() => _hanyaBarter = !_hanyaBarter),
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(minHeight: AppSizes.minTapTarget),
              child: Row(
                children: [
                  Icon(Icons.swap_horiz_rounded,
                      size: AppSizes.iconSm,
                      color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text('Bisa barter', style: text.titleMedium),
                  ),
                  Switch(
                    value: _hanyaBarter,
                    onChanged: (v) => setState(() => _hanyaBarter = v),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        AppButton(
          key: const Key('filter-apply'),
          label: 'Terapkan',
          onPressed: () => Navigator.pop<HomeFilterResult>(context, (
            sort: _sort,
            hargaMaks: _noLimit ? null : _harga.round(),
            hanyaTersedia: _hanyaTersedia,
            hanyaBarter: _hanyaBarter,
          )),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextButton(
          onPressed: () => Navigator.pop<HomeFilterResult>(context, _defaults),
          child: const Text('Atur ulang'),
        ),
      ],
    );
  }
}
