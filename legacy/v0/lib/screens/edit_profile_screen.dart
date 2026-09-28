import 'package:flutter/material.dart';
import '../data/app_store.dart';
import '../models.dart';
import '../validators.dart';
import '../widgets/common.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _campusController;
  late TextEditingController _bioController;

  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _campusController = TextEditingController();
    _bioController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final store = AppScope.of(context);
      final profile = store.userProfile;
      _nameController.text = profile.name;
      _emailController.text = profile.email;
      _phoneController.text = profile.phone;
      _campusController.text = profile.campus;
      _bioController.text = profile.bio;
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _campusController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final store = AppScope.of(context);
    final updatedProfile = UserProfile(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      campus: _campusController.text.trim(),
      bio: _bioController.text.trim(),
    );

    final success = await store.updateProfile(updatedProfile);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil berhasil diperbarui!')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memperbarui profil: ${store.errorMessage}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profil & Pengaturan'),
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
                  labelText: 'Nama Lengkap *',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (val) => Validators.validateMinLength(val, 3, 'Nama lengkap'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email *',
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (val) => Validators.validateRequired(val, 'Email'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Nomor WhatsApp *',
                  prefixIcon: Icon(Icons.phone),
                ),
                validator: (val) => Validators.validatePhone(val),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _campusController,
                decoration: const InputDecoration(
                  labelText: 'Kampus / Domisili *',
                  prefixIcon: Icon(Icons.school),
                ),
                validator: (val) => Validators.validateRequired(val, 'Kampus'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bioController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Bio / Deskripsi Singkat',
                  prefixIcon: Icon(Icons.info_outline),
                ),
              ),
              const SizedBox(height: 24),
              Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Mode Gelap'),
                      value: store.darkMode,
                      onChanged: (_) => store.toggleDarkMode(),
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      title: const Text('Simulasi Gagal Jaringan'),
                      subtitle: const Text('Untuk pengujian error handling'),
                      value: store.failureSimulated,
                      onChanged: (_) => store.toggleFailureSimulation(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: store.isSaving ? null : _handleSave,
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
                    : const Text('Simpan Perubahan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
