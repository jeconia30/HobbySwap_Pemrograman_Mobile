import 'package:flutter/material.dart';

import '../../../core/widgets/app_placeholder_page.dart';

/// Placeholder sampai M7.
class AktivitasPage extends StatelessWidget {
  const AktivitasPage({super.key});

  @override
  Widget build(BuildContext context) => const AppPlaceholderPage(
        title: 'Aktivitas',
        icon: Icons.notifications_none_rounded,
        message: 'Notifikasi pengajuan, persetujuan, dan pengingat akan '
            'tampil di sini.',
        showBack: true,
      );
}
