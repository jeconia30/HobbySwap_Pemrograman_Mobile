import 'package:flutter/material.dart';
import '../widgets/common.dart';

class ItemDetailScreen extends StatelessWidget {
  final String id;

  const ItemDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final item = store.getItemById(id);

    if (item == null) {
      return const NotFoundScreen();
    }

    final category = store.getCategoryById(item.categoryId);

    return Scaffold(
      appBar: AppBar(
        title: Text(item.name),
        actions: [
          if (item.isMine)
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Edit Barang',
              onPressed: () {
                Navigator.pushNamed(context, '/item/$id/edit');
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image banner
            SizedBox(
              height: 250,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    item.imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: const Color(0xFF0F6E56).withOpacity(0.15),
                      child: const Center(
                        child: Icon(Icons.image_not_supported, size: 64, color: Color(0xFF0F6E56)),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: AvailabilityBadge(isAvailable: item.isAvailable),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (category != null)
                        Chip(
                          avatar: const Icon(Icons.category, size: 16),
                          label: Text(category.name),
                        ),
                      const SizedBox(width: 8),
                      if (item.isMine)
                        Chip(
                          backgroundColor: Colors.amber.shade100,
                          label: const Text('Milik Saya', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.grey, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        item.location,
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.person, color: Colors.grey, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        'Pemilik: ${item.ownerName}',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  Text(
                    'Deskripsi Barang',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.description,
                    style: const TextStyle(fontSize: 14, height: 1.5),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: item.isMine
            ? OutlinedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/item/$id/edit');
                },
                icon: const Icon(Icons.edit),
                label: const Text('Edit Barang Saya'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              )
            : FilledButton.icon(
                onPressed: item.isAvailable
                    ? () {
                        Navigator.pushNamed(context, '/item/$id/borrow');
                      }
                    : null,
                icon: const Icon(Icons.send),
                label: Text(item.isAvailable ? 'Ajukan Peminjaman' : 'Barang Sedang Dipinjam'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  backgroundColor: const Color(0xFF0F6E56),
                ),
              ),
      ),
    );
  }
}
