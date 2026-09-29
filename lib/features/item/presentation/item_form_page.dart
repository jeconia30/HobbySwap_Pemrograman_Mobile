import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/haptics.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_back_button.dart';
import '../../../core/widgets/app_bottom_sheet.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_chip.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_error_banner.dart';
import '../../../core/widgets/app_sticky_bottom.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/app_upload_slot.dart';
import '../../auth/presentation/auth_controller.dart';
import '../data/item_providers.dart';
import '../domain/item.dart';
import '../domain/item_repository.dart';
import '../domain/kategori.dart';
import 'kategori_visual.dart';
import '../../../core/constants/app_strings.dart';
import '../../booking/domain/booking_rules.dart';
import '../../../core/utils/formatters.dart';

/// Penanda foto simulasi (UI-first; belum kamera/galeri asli).
const _fotoSimulasi = 'simulasi://foto-barang';

enum _FotoChoice { camera, gallery, remove }

/// Tambah barang ([itemId] null) atau ubah barang milik sendiri.
class ItemFormPage extends ConsumerStatefulWidget {
  const ItemFormPage({super.key, this.itemId});

  final String? itemId;

  @override
  ConsumerState<ItemFormPage> createState() => _ItemFormPageState();
}

class _ItemFormPageState extends ConsumerState<ItemFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _judul = TextEditingController();
  final _harga = TextEditingController();
  final _lokasi = TextEditingController();
  final _deskripsi = TextEditingController();

  /// "Lanjut" di Nama barang langsung ke Harga (chip kategori dipilih dengan ketuk).
  final _hargaFocus = FocusNode();
  final _deskripsiFocus = FocusNode();
  final _lokasiFocus = FocusNode();
  final _denda = TextEditingController();
  bool _tanpaDenda = false;
  bool _bisaBarter = false;
  final _minatBarter = <Kategori>{};
  final _kategoriField = GlobalKey<FormFieldState<Kategori>>();

  Kategori? _kategori;
  List<String> _foto = const [];
  bool _submitting = false;
  bool _submittedOnce = false;
  bool _prefilled = false;
  String? _error;

  bool get _isEdit => widget.itemId != null;

  @override
  void initState() {
    super.initState();
    final itemId = widget.itemId;
    if (itemId == null) {
      _lokasi.text = ref.read(authControllerProvider)?.fakultas ?? '';
      _prefilled = true;
    }
  }

  /// Isi form sekali saat data barang pertama kali tersedia (mode ubah).
  void _prefill(Item item) {
    if (_prefilled) return;
    _prefilled = true;
    _judul.text = item.judul;
    _harga.text = '${item.hargaPerHari}';
    _tanpaDenda = item.dendaPerHari == 0;
    _bisaBarter = item.bisaBarter;
    _minatBarter
      ..clear()
      ..addAll(item.minatBarter);
    _denda.text = _tanpaDenda ? '' : '${item.dendaPerHari}';
    _lokasi.text = item.lokasiKampus;
    _deskripsi.text = item.deskripsi;
    _kategori = item.kategori;
    _foto = item.daftarFoto;
  }

  @override
  void dispose() {
    _hargaFocus.dispose();
    _deskripsiFocus.dispose();
    _lokasiFocus.dispose();
    _denda.dispose();
    _judul.dispose();
    _harga.dispose();
    _lokasi.dispose();
    _deskripsi.dispose();
    super.dispose();
  }

  void _back() =>
      context.canPop() ? context.pop() : context.go(AppRoutes.barangSaya);

  Future<void> _pickFoto() async {
    final choice = await showAppBottomSheet<_FotoChoice>(
      context,
      builder: (sheet) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AppSheetTitle('Foto barang'),
          AppSheetAction(
            icon: Icons.photo_camera_outlined,
            label: 'Ambil foto',
            onTap: () => Navigator.pop(sheet, _FotoChoice.camera),
          ),
          AppSheetAction(
            icon: Icons.photo_library_outlined,
            label: 'Pilih dari galeri',
            onTap: () => Navigator.pop(sheet, _FotoChoice.gallery),
          ),
          if (_foto.isNotEmpty)
            AppSheetAction(
              icon: Icons.delete_outline_rounded,
              label: 'Hapus foto',
              destructive: true,
              onTap: () => Navigator.pop(sheet, _FotoChoice.remove),
            ),
        ],
      ),
    );
    if (choice == null || !mounted) return;
    setState(
      () => _foto = choice == _FotoChoice.remove
          ? const []
          : const [_fotoSimulasi],
    );
  }

  Future<void> _submit() async {
    if (_submitting) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _submittedOnce = true;
      _error = null;
    });
    if (!_formKey.currentState!.validate()) return;

    final input = ItemInput(
      judul: _judul.text,
      deskripsi: _deskripsi.text,
      kategori: _kategori!,
      hargaPerHari: int.parse(_harga.text.trim()),
      lokasiKampus: _lokasi.text,
      daftarFoto: _foto,
      dendaPerHari: _tanpaDenda ? 0 : int.parse(_denda.text.trim()),
      bisaBarter: _bisaBarter,
      minatBarter: _bisaBarter ? _minatBarter.toList() : const [],
    );
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _submitting = true);
    try {
      final repo = ref.read(itemRepositoryProvider);
      final item = _isEdit
          ? await repo.update(widget.itemId!, input)
          : await repo.create(input);
      ref
        ..invalidate(myItemsProvider)
        ..invalidate(itemByIdProvider(item.id));
      if (!mounted) return;
      if (!_isEdit) hapticAksiPenting();
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              _isEdit
                  ? 'Perubahan disimpan.'
                  : 'Barangmu sudah tayang di HobbySwap!',
            ),
          ),
        );
      _back();
    } on ItemException catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = AppTeks.koneksiPutus;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _isEdit ? 'Ubah barang' : 'Sewakan barang';

    Widget message(
      IconData icon,
      String text, [
      String? action,
      VoidCallback? onAction,
    ]) => _Scaffold(
      title: title,
      onBack: _back,
      body: Padding(
        padding: const EdgeInsets.only(top: AppSpacing.xxxl),
        child: AppEmptyState(
          icon: icon,
          title: text,
          actionLabel: action,
          onAction: onAction,
        ),
      ),
    );

    if (_isEdit) {
      final async = ref.watch(itemByIdProvider(widget.itemId!));
      final userId = ref.watch(authControllerProvider)?.id;
      switch (async) {
        case AsyncError():
          return message(
            Icons.wifi_off_rounded,
            AppTeks.koneksiPutus,
            AppTeks.cobaLagi,
            () {
              ref.invalidate(itemByIdProvider(widget.itemId!));
            },
          );
        case AsyncData(value: null):
          return message(
            Icons.inventory_2_outlined,
            'Barang ini sudah tidak ada.',
          );
        case AsyncData(:final value?) when value.item.ownerId != userId:
          return message(
            Icons.lock_outline_rounded,
            'Kamu hanya bisa mengubah barangmu sendiri.',
          );
        case AsyncData(:final value?):
          _prefill(value.item);
        default:
          return _Scaffold(
            title: title,
            onBack: _back,
            body: const SizedBox.shrink(),
          );
      }
    }

    return _Scaffold(
      title: title,
      onBack: _submitting ? null : _back,
      bottom: AppStickyBottom(
        children: [
          AppErrorSlot(message: _error),
          AppButton(
            key: const Key('form-barang-simpan'),
            label: _isEdit ? 'Simpan perubahan' : 'Pasang barang',
            isLoading: _submitting,
            onPressed: _submit,
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: _submittedOnce
            ? AutovalidateMode.onUserInteraction
            : AutovalidateMode.disabled,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppUploadSlot(
              key: const Key('form-barang-foto'),
              icon: Icons.add_a_photo_outlined,
              emptyTitle: 'Tambah foto barang',
              emptySubtitle: 'Foto yang terang bikin barangmu cepat disewa.',
              filledTitle: 'Foto barang',
              filledStatus: 'Terunggah · ${_foto.length} foto',
              enabled: !_submitting,
              preview: _foto.isEmpty
                  ? null
                  : _FotoPreview(kategori: _kategori ?? Kategori.lainnya),
              onTap: _pickFoto,
            ),
            const SizedBox(height: AppSpacing.xl),
            AppTextField(
              key: const Key('form-barang-judul'),
              label: 'Nama barang',
              hint: 'Contoh: Tenda Dome 4 Orang',
              controller: _judul,
              enabled: !_submitting,
              validator: ItemValidators.judul,
              maxLength: ItemValidators.judulMaks,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) => _hargaFocus.requestFocus(),
            ),
            const SizedBox(height: AppSpacing.md),
            _KategoriField(
              fieldKey: _kategoriField,
              value: _kategori,
              enabled: !_submitting,
              onChanged: (k) => setState(() => _kategori = k),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              key: const Key('form-barang-harga'),
              label: 'Harga sewa per hari',
              focusNode: _hargaFocus,
              hint: '25000',
              prefixText: 'Rp ',
              controller: _harga,
              enabled: !_submitting,
              validator: ItemValidators.harga,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(7),
              ],
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: AppSpacing.lg),
            _DendaField(
              controller: _denda,
              harga: _harga,
              tanpaDenda: _tanpaDenda,
              enabled: !_submitting,
              onTanpaDenda: (v) => setState(() {
                _tanpaDenda = v;
                if (v) _denda.clear();
              }),
              onSubmitted: () => _lokasiFocus.requestFocus(),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              key: const Key('form-barang-lokasi'),
              label: 'Lokasi ambil',
              focusNode: _lokasiFocus,
              hint: 'Contoh: FT USU, Pintu 4',
              controller: _lokasi,
              enabled: !_submitting,
              validator: ItemValidators.lokasi,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              // Lewati chip titik kampus; langsung ke Deskripsi.
              onFieldSubmitted: (_) => _deskripsiFocus.requestFocus(),
            ),
            const SizedBox(height: AppSpacing.sm),
            _TitikKampusChips(controller: _lokasi, enabled: !_submitting),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              key: const Key('form-barang-deskripsi'),
              label: 'Deskripsi',
              focusNode: _deskripsiFocus,
              hint:
                  'Kondisi, kelengkapan, dan hal yang perlu diperhatikan '
                  'penyewa.',
              controller: _deskripsi,
              enabled: !_submitting,
              validator: ItemValidators.deskripsi,
              maxLength: ItemValidators.deskripsiMaks,
              minLines: 4,
              maxLines: 8,
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: AppSpacing.lg),
            _BarterField(
              aktif: _bisaBarter,
              minat: _minatBarter,
              enabled: !_submitting,
              onAktif: (v) => setState(() => _bisaBarter = v),
              onMinat: (k) => setState(
                () => _minatBarter.contains(k)
                    ? _minatBarter.remove(k)
                    : _minatBarter.add(k),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Scaffold extends StatelessWidget {
  const _Scaffold({
    required this.title,
    required this.onBack,
    required this.body,
    this.bottom,
  });

  final String title;
  final VoidCallback? onBack;
  final Widget body;
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageHome,
                  AppSpacing.md,
                  AppSpacing.pageHome,
                  AppSpacing.xl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        AppBackButton(onPressed: onBack),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Semantics(
                            header: true,
                            child: Text(
                              title,
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    body,
                  ],
                ),
              ),
            ),
            ?bottom,
          ],
        ),
      ),
    );
  }
}

class _KategoriField extends StatelessWidget {
  const _KategoriField({
    required this.fieldKey,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final GlobalKey<FormFieldState<Kategori>> fieldKey;
  final Kategori? value;
  final bool enabled;
  final ValueChanged<Kategori> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FormField<Kategori>(
      key: fieldKey,
      initialValue: value,
      validator: (_) => value == null ? 'Pilih kategori dulu' : null,
      builder: (field) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Kategori',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final k in Kategori.values)
                AppChip(
                  key: Key('form-kategori-${k.name}'),
                  label: k.label,
                  selected: value == k,
                  onTap: () {
                    if (!enabled) return;
                    onChanged(k);
                    field.didChange(k);
                  },
                ),
            ],
          ),
          if (field.hasError)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: Text(
                field.errorText!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FotoPreview extends StatelessWidget {
  const _FotoPreview({required this.kategori});

  final Kategori kategori;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: kategori.tileColor,
      child: Center(
        child: Icon(
          kategori.icon,
          color: AppPalette.cream,
          size: AppSizes.iconTile * 0.6,
        ),
      ),
    );
  }
}

/// Pilihan cepat titik ambil (sama dengan usulan COD di Pesan).
class _TitikKampusChips extends StatelessWidget {
  const _TitikKampusChips({required this.controller, required this.enabled});

  final TextEditingController controller;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final (i, t) in titikKampus.indexed) ...[
              if (i > 0) const SizedBox(width: AppSpacing.sm),
              AppChip(
                key: Key('titik-$t'),
                label: t,
                selected: value.text.trim() == t,
                onTap: () {
                  if (enabled) controller.text = t;
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// "Denda telat per hari": saran 50% harga sewa atau "Tanpa denda".
class _DendaField extends StatelessWidget {
  const _DendaField({
    required this.controller,
    required this.harga,
    required this.tanpaDenda,
    required this.enabled,
    required this.onTanpaDenda,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final TextEditingController harga;
  final bool tanpaDenda;
  final bool enabled;
  final ValueChanged<bool> onTanpaDenda;
  final VoidCallback onSubmitted;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([harga, controller]),
      builder: (context, _) {
        final saran = saranDenda(int.tryParse(harga.text.trim()) ?? 0);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              key: const Key('form-barang-denda'),
              label: 'Denda telat per hari',
              hint: saran > 0 ? '$saran' : '12500',
              prefixText: 'Rp ',
              controller: controller,
              enabled: enabled && !tanpaDenda,
              validator: (v) => ItemValidators.denda(v, tanpaDenda: tanpaDenda),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(7),
              ],
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) => onSubmitted(),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              children: [
                if (saran > 0)
                  AppChip(
                    key: const Key('denda-saran'),
                    label: 'Saran ${formatRupiah(saran)} (50%)',
                    selected: !tanpaDenda && controller.text.trim() == '$saran',
                    onTap: () {
                      if (!enabled) return;
                      onTanpaDenda(false);
                      controller.text = '$saran';
                    },
                  ),
                AppChip(
                  key: const Key('denda-tanpa'),
                  label: 'Tanpa denda',
                  selected: tanpaDenda,
                  onTap: () {
                    if (enabled) onTanpaDenda(!tanpaDenda);
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

/// Bagian "Barter": terima tawaran barter + kategori yang dicari.
class _BarterField extends StatelessWidget {
  const _BarterField({
    required this.aktif,
    required this.minat,
    required this.enabled,
    required this.onAktif,
    required this.onMinat,
  });

  final bool aktif;
  final Set<Kategori> minat;
  final bool enabled;
  final ValueChanged<bool> onAktif;
  final ValueChanged<Kategori> onMinat;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = theme.textTheme;
    return AppCard(
      key: const Key('form-barang-barter'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Barter', style: text.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Barter = saling pinjam untuk tanggal yang sama, lalu sama-sama '
            'dikembalikan.',
            style: text.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          // Material sendiri: latar kartu tidak menutupi efek ink ListTile.
          Material(
            type: MaterialType.transparency,
            child: MergeSemantics(
              child: SwitchListTile(
                key: const Key('form-bisa-barter'),
                contentPadding: EdgeInsets.zero,
                title: Text('Terima tawaran barter', style: text.bodyMedium),
                value: aktif,
                onChanged: enabled ? onAktif : null,
              ),
            ),
          ),
          if (aktif) ...[
            Text('Barang yang kamu cari', style: text.labelMedium),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              children: [
                for (final k in Kategori.values)
                  AppChip(
                    key: Key('minat-${k.name}'),
                    label: k.label,
                    selected: minat.contains(k),
                    showCheck: true,
                    onTap: () {
                      if (enabled) onMinat(k);
                    },
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
