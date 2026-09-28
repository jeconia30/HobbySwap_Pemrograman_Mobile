import 'package:flutter/material.dart';
import '../data/app_store.dart';
import '../models.dart';
import '../validators.dart';
import '../widgets/common.dart';

class ItemFormScreen extends StatefulWidget {
  final String? itemId;

  const ItemFormScreen({super.key, this.itemId});

  @override
  State<ItemFormScreen> createState() => _ItemFormScreenState();
}

class _ItemFormScreenState extends State<ItemFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _locationController;
  late TextEditingController _descriptionController;

  String? _selectedCategoryId;
  bool _isAvailable = true;
  Item? _existingItem;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _locationController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.itemId != null && _existingItem == null) {
      final store = AppScope.of(context);
      _existingItem = store.getItemById(widget.itemId!);
      if (_existingItem != null) {
        _nameController.text = _existingItem!.name;
        _locationController.text = _existingItem!.location;
        _descriptionController.text = _existingItem!.description;
        _selectedCategoryId = _existingItem!.categoryId;
        _isAvailable = _existingItem!.isAvailable;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final store = AppScope.of(context);
    final userProfile = store.userProfile;

    final newItem = Item(
      id: _existingItem?.id ?? 'item-${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text.trim(),
      categoryId: _selectedCategoryId ?? 'cat-1',
      location: _locationController.text.trim(),
      imagePath: _existingItem?.imagePath ?? 'assets/items/sepatu.jpg',
      description: _descriptionController.text.trim(),
      ownerName: userProfile.name,
      isAvailable: _isAvailable,
      isMine: true,
    );

    final success = await store.saveItem(newItem);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.itemId == null
                ? 'Barang berhasil ditambahkan!'
                : 'Barang berhasil diperbarui!'),
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan barang: ${store.errorMessage}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);

    if (widget.itemId != null && _existingItem == null && !store.isLoading) {
      return const NotFoundScreen();
    }

    final isEdit = widget.itemId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Barang Saya' : 'Tambah Barang Baru'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Barang *',
                  hintText: 'Contoh: Sepatu Lari Adidas 42',
                  prefixIcon: Icon(Icons.inventory),
                ),
                validator: (val) => Validators.validateMinLength(val, 3, 'Nama barang'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategoryId,
                decoration: const InputDecoration(
                  labelText: 'Kategori *',
                  prefixIcon: Icon(Icons.category),
                ),
                items: store.categories.map<DropdownMenuItem<String>>((cat) {
                  return DropdownMenuItem<String>(
                    value: cat.id,
                    child: Text(cat.name),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedCategoryId = val),
                validator: (val) => Validators.validateCategory(val),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Lokasi Pengambilan *',
                  hintText: 'Contoh: Kampus A / Kos Melati 12',
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: (val) => Validators.validateRequired(val, 'Lokasi'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi Barang *',
                  hintText: 'Jelaskan kondisi barang, kelengkapan, dan aturan khusus...',
                  prefixIcon: Icon(Icons.description),
                ),
                validator: (val) => Validators.validateMinLength(val, 10, 'Deskripsi'),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Status Tersedia untuk Dipinjam'),
                subtitle: const Text('Nonaktifkan jika barang sedang dipakai sendiri'),
                value: _isAvailable,
                onChanged: (val) => setState(() => _isAvailable = val),
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: store.isSaving ? null : _handleSubmit,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  backgroundColor: const Color(0xFF0F6E56),
                ),
                child: store.isSaving
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text(isEdit ? 'Simpan Perubahan' : 'Tambahkan Barang'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
