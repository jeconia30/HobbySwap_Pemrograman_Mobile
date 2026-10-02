import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/dates.dart';
import '../../../core/widgets/app_button.dart';
import '../../item/domain/kategori.dart';
import '../../item/presentation/kategori_visual.dart';
import '../domain/chat_message.dart';

/// Pill kecil di tengah: pemisah tanggal ("Hari ini", "Sen, 21 Sep").
class ChatTanggalPill extends StatelessWidget {
  const ChatTanggalPill(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.xs),
        decoration: BoxDecoration(
          color: AppColors.of(context).surfaceAlt,
          borderRadius: AppRadius.pillAll,
        ),
        child: Text(
          label,
          style: theme.textTheme.labelSmall
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ),
    );
  }
}

/// Pesan sistem dari kejadian sewa: pill di tengah dengan ikon status.
class ChatSistemPill extends StatelessWidget {
  const ChatSistemPill(this.message, {super.key});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final icon = switch (message.kejadian) {
      KejadianSewa.dikirim => Icons.send_rounded,
      KejadianSewa.disetujui => Icons.check_circle_outline_rounded,
      KejadianSewa.ditolak => Icons.cancel_outlined,
      KejadianSewa.serahTerima => Icons.handshake_outlined,
      KejadianSewa.pengembalian => Icons.assignment_turned_in_outlined,
      KejadianSewa.dibatalkan => Icons.event_busy_outlined,
      KejadianSewa.barterDikirim ||
      KejadianSewa.barterDiminta ||
      KejadianSewa.barterDisetujui =>
        Icons.swap_horiz_rounded,
      null => Icons.info_outline_rounded,
    };
    return Center(
      child: Container(
        key: Key('sistem-${message.id}'),
        margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.tight),
        decoration: BoxDecoration(
          color: AppColors.of(context).surfaceAlt,
          borderRadius: AppRadius.pillAll,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ExcludeSemantics(
              child: Icon(icon, size: AppSpacing.md + AppSpacing.xs / 2,
                  color: muted),
            ),
            const SizedBox(width: AppSpacing.tight),
            Flexible(
              child: Text(
                '${message.isi} · ${formatJam(message.sentAt)}',
                textAlign: TextAlign.center,
                style: theme.textTheme.labelSmall?.copyWith(color: muted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Banner keamanan di awal obrolan baru.
class ChatBannerKeamanan extends StatelessWidget {
  const ChatBannerKeamanan({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = AppColors.of(context);
    return Container(
      key: const Key('banner-keamanan'),
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.accentSoft,
        borderRadius: AppRadius.noteAll,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExcludeSemantics(
            child: Icon(Icons.shield_outlined,
                color: colors.accentText, size: AppSizes.iconSm),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Demi keamanan, COD-lah di area kampus dan jangan pernah '
              'bagikan password akunmu.',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}

/// Satu pesan pengguna: gelembung teks, foto, atau kartu COD, rata kanan
/// untuk [milikku]. [rapatAtas]/[rapatBawah] = bersambung dengan pesan
/// pengirim yang sama (sudut dirapikan, jam hanya di pesan terakhir).
class ChatGelembung extends StatelessWidget {
  const ChatGelembung({
    super.key,
    required this.message,
    required this.milikku,
    required this.kategori,
    this.rapatAtas = false,
    this.rapatBawah = false,
    this.onSetujuCod,
    this.onUsulLainCod,
    this.bawah,
  });

  final ChatMessage message;
  final bool milikku;
  final Kategori kategori;
  final bool rapatAtas;
  final bool rapatBawah;
  final VoidCallback? onSetujuCod;
  final VoidCallback? onUsulLainCod;

  /// Tambahan di bawah gelembung (mis. peringatan penipuan dari AI).
  final Widget? bawah;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final colors = AppColors.of(context);

    const besar = Radius.circular(AppRadius.bubble);
    const kecil = Radius.circular(AppRadius.bubbleTail);
    final radius = milikku
        ? BorderRadius.only(
            topLeft: besar,
            bottomLeft: besar,
            topRight: rapatAtas ? kecil : besar,
            bottomRight: kecil,
          )
        : BorderRadius.only(
            topRight: besar,
            bottomRight: besar,
            topLeft: rapatAtas ? kecil : besar,
            bottomLeft: kecil,
          );

    final Widget isi = switch (message.tipe) {
      TipePesan.lokasiCod => ChatKartuCod(
          message: message,
          milikku: milikku,
          onSetuju: onSetujuCod,
          onUsulLain: onUsulLainCod,
        ),
      TipePesan.foto => Semantics(
          label: 'Foto',
          image: true,
          child: Container(
            width: AppSizes.fotoPesan.width,
            height: AppSizes.fotoPesan.height,
            decoration: BoxDecoration(
              color: kategori.tileColor,
              borderRadius: const BorderRadius.all(
                  Radius.circular(AppRadius.fotoPesan)),
            ),
            child: const Icon(Icons.image_outlined,
                color: AppPalette.cream, size: AppSizes.iconLg),
          ),
        ),
      _ => Container(
          padding: AppSpacing.bubble,
          decoration: BoxDecoration(
            color: milikku ? scheme.primary : scheme.surface,
            borderRadius: radius,
            border: milikku ? null : Border.all(color: colors.border),
          ),
          child: Text(
            message.isi,
            style: theme.textTheme.bodyLarge?.merge(AppTextStyles.bubble)
                .copyWith(color: milikku ? scheme.onPrimary : scheme.onSurface),
          ),
        ),
    };

    final dibaca = message.readAt != null;
    final meta = Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs / 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            formatJam(message.sentAt),
            style: theme.textTheme.labelSmall
                ?.merge(AppTextStyles.chatMeta)
                .copyWith(color: scheme.onSurfaceVariant),
          ),
          if (milikku) ...[
            const SizedBox(width: AppSpacing.xs),
            Semantics(
              label: dibaca ? 'Dibaca' : 'Terkirim',
              child: Icon(
                dibaca ? Icons.done_all_rounded : Icons.done_rounded,
                key: Key('centang-${message.id}'),
                size: AppSizes.iconXs,
                color: dibaca ? colors.accentText : scheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );

    return LayoutBuilder(
      builder: (context, box) => Align(
        alignment: milikku ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
              maxWidth: box.maxWidth * AppSizes.bubbleMaxFraction),
          child: Column(
            key: Key('bubble-${message.id}'),
            crossAxisAlignment:
                milikku ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [isi, ?bawah, if (!rapatBawah) meta],
          ),
        ),
      ),
    );
  }
}

/// Kartu usulan titik COD. Penerima bisa setuju atau minta usulan lain.
class ChatKartuCod extends StatelessWidget {
  const ChatKartuCod({
    super.key,
    required this.message,
    required this.milikku,
    this.onSetuju,
    this.onUsulLain,
  });

  final ChatMessage message;
  final bool milikku;
  final VoidCallback? onSetuju;
  final VoidCallback? onUsulLain;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = theme.textTheme;
    final scheme = theme.colorScheme;
    final colors = AppColors.of(context);
    final cod = message.cod!;
    final muted = text.bodySmall?.copyWith(color: scheme.onSurfaceVariant);

    final Widget status = switch (cod.status) {
      StatusCod.menunggu when !milikku => Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            AppButton(
              key: Key('cod-setuju-${message.id}'),
              label: 'Setuju',
              compact: true,
              onPressed: onSetuju,
            ),
            AppButton(
              key: Key('cod-usul-${message.id}'),
              label: 'Usul lain',
              compact: true,
              variant: AppButtonVariant.secondary,
              onPressed: onUsulLain,
            ),
          ],
        ),
      StatusCod.menunggu => Text('Menunggu jawaban…', style: muted),
      StatusCod.disetujui => Text(
          'Disetujui ✓',
          key: Key('cod-disetujui-${message.id}'),
          style: text.labelMedium?.copyWith(
              color: colors.verified, fontWeight: FontWeight.w800),
        ),
      StatusCod.usulLain => Text(
          'Minta usulan lain',
          key: Key('cod-usullain-${message.id}'),
          style: text.labelMedium?.copyWith(
              color: scheme.onSurfaceVariant, fontWeight: FontWeight.w700),
        ),
    };

    return Container(
      key: Key('cod-${message.id}'),
      width: AppSizes.codCard,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius:
            const BorderRadius.all(Radius.circular(AppRadius.bubble)),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: AppSizes.codIcon,
                height: AppSizes.codIcon,
                decoration: BoxDecoration(
                  color: colors.accentSoft,
                  borderRadius: AppRadius.previewAll,
                ),
                child: Icon(Icons.location_on_outlined,
                    color: colors.accentText, size: AppSizes.iconSm),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Usulan titik COD', style: muted),
                    Text(
                      cod.lokasi,
                      style: text.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Icon(Icons.schedule_rounded,
                  size: AppSizes.iconXs, color: scheme.onSurfaceVariant),
              const SizedBox(width: AppSpacing.xs),
              Flexible(
                child: Text(
                  '${formatTanggalPendek(cod.waktu)} · ${formatJam(cod.waktu)}',
                  style: text.bodyMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          status,
        ],
      ),
    );
  }
}
