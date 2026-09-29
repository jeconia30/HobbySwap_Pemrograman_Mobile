import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/dates.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/item_thumb.dart';
import '../../../core/widgets/status_badge.dart';
import '../../booking/domain/booking.dart';
import '../../booking/presentation/barter_widgets.dart';
import '../domain/chat_repository.dart';

/// Satu tombol konteks di kartu transaksi: label + rute tujuannya.
typedef AksiTransaksi = ({String label, String rute});

/// Aksi yang paling relevan untuk viewer sesuai status sewa di thread.
/// [dinilai] = id sewa yang sudah diberi ulasan oleh viewer.
AksiTransaksi aksiTransaksi(ChatThreadView v, Set<String> dinilai) {
  final lihat = (label: 'Lihat barang', rute: AppRoutes.barangDetail(v.item.id));
  final b = v.booking;
  if (b == null) return lihat;
  return switch (b.status) {
    StatusBooking.menunggu when v.sayaPemilik =>
      (label: 'Tinjau', rute: AppRoutes.pengajuanMasuk),
    // Barter: kedua pihak meminjam, jadi keduanya mengisi checklist ambil.
    StatusBooking.disetujui when !v.sayaPemilik || b.barter =>
      (label: 'Checklist ambil', rute: AppRoutes.checklist(b.id)),
    StatusBooking.berlangsung =>
      (label: 'Checklist kembali', rute: AppRoutes.checklist(b.id, akhir: true)),
    StatusBooking.selesai when !dinilai.contains(b.id) =>
      (label: 'Beri rating', rute: AppRoutes.rating(b.id)),
    _ => lihat,
  };
}

/// Kartu ringkas barang & sewa yang menempel di bawah header ruang obrolan.
class ChatKartuTransaksi extends StatelessWidget {
  const ChatKartuTransaksi({
    super.key,
    required this.view,
    required this.dinilai,
  });

  final ChatThreadView view;
  final Set<String> dinilai;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = theme.textTheme;
    final scheme = theme.colorScheme;
    final b = view.booking;
    final aksi = aksiTransaksi(view, dinilai);
    final tawaran = view.itemTawaran;
    final barter = b != null && b.barter && tawaran != null;
    final ringkas = b == null
        ? '${formatRupiah(view.item.hargaPerHari)}/hari'
        : barter
            ? 'Barter · ${formatRentangPendek(b.tanggalMulai, b.tanggalKembali)}'
            : '${formatRentangPendek(b.tanggalMulai, b.tanggalKembali)} · '
                '${formatRupiah(b.totalHarga)}';

    return Container(
      key: const Key('kartu-transaksi'),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.pageHome, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(bottom: BorderSide(color: AppColors.of(context).border)),
      ),
      child: Row(
        children: [
          if (barter)
            BarterTileTumpuk(
                atas: view.item, bawah: tawaran, size: AppSizes.chatTile)
          else
            ItemThumb(kategori: view.item.kategori, size: AppSizes.chatTile),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  barter
                      ? '${view.item.judul} · ${tawaran.judul}'
                      : view.item.judul,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: AppSpacing.xs / 2),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      ringkas,
                      style: text.bodySmall
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                    if (b != null) StatusBadge(b.status, compact: true),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          // Flexible: label panjang / font besar dipotong, bukan overflow.
          Flexible(
            flex: 2,
            child: AppButton(
              key: const Key('chat-aksi'),
              label: aksi.label,
              compact: true,
              variant: AppButtonVariant.secondary,
              onPressed: () => context.push(aksi.rute),
            ),
          ),
        ],
      ),
    );
  }
}
