import 'package:flutter/material.dart';
import '../data/app_store.dart';
import '../models.dart';
import '../widgets/common.dart';

class LoanDetailScreen extends StatelessWidget {
  final String id;

  const LoanDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final loan = store.getLoanById(id);

    if (loan == null) {
      return const NotFoundScreen();
    }

    final item = store.getItemById(loan.itemId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pengajuan Pinjaman'),
        actions: [
          if (loan.status == LoanStatus.menunggu)
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Edit Pengajuan',
              onPressed: () {
                Navigator.pushNamed(context, '/loan/$id/edit');
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Header Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Status Pengajuan',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        StatusBadge(status: loan.status),
                      ],
                    ),
                    const Icon(Icons.info_outline, color: Color(0xFF0F6E56), size: 32),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Item Summary Card
            if (item != null)
              Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey.shade200,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.asset(
                      item.imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported),
                    ),
                  ),
                  title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Pemilik: ${item.ownerName}\nLokasi: ${item.location}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pushNamed(context, '/item/${item.id}');
                  },
                ),
              ),
            const SizedBox(height: 16),
            // Borrower & Date Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informasi Peminjaman',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const Divider(height: 20),
                    _buildInfoRow('Nama Peminjam', loan.borrowerName),
                    const SizedBox(height: 8),
                    _buildInfoRow('No. WhatsApp', loan.borrowerPhone),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      'Tanggal Mulai',
                      '${loan.startDate.day}/${loan.startDate.month}/${loan.startDate.year}',
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      'Tanggal Selesai',
                      '${loan.endDate.day}/${loan.endDate.month}/${loan.endDate.year}',
                    ),
                    const SizedBox(height: 12),
                    const Text('Tujuan Peminjaman:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text(loan.purpose, style: const TextStyle(fontSize: 13, height: 1.4)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Action Buttons
            if (loan.status == LoanStatus.menunggu) ...[
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/loan/$id/edit');
                },
                icon: const Icon(Icons.edit),
                label: const Text('Edit Pengajuan'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
              const SizedBox(height: 8),
            ],
            OutlinedButton.icon(
              onPressed: () async {
                final confirm = await showConfirmDialog(
                  context: context,
                  title: 'Hapus Pengajuan',
                  content: 'Apakah Anda yakin ingin menghapus riwayat pengajuan ini?',
                );
                if (confirm == true) {
                  final success = await store.deleteLoan(loan.id);
                  if (context.mounted) {
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Pengajuan berhasil dihapus')),
                      );
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Gagal menghapus: ${store.errorMessage}')),
                      );
                    }
                  }
                }
              },
              icon: const Icon(Icons.delete, color: Colors.red),
              label: const Text('Hapus Pengajuan', style: TextStyle(color: Colors.red)),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                side: const BorderSide(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
      ],
    );
  }
}
