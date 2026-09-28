import 'package:flutter/material.dart';
import '../data/app_store.dart';
import '../models.dart';
import '../validators.dart';
import '../widgets/common.dart';

class LoanFormScreen extends StatefulWidget {
  final String? itemId;
  final String? loanId;

  const LoanFormScreen({super.key, this.itemId, this.loanId});

  @override
  State<LoanFormScreen> createState() => _LoanFormScreenState();
}

class _LoanFormScreenState extends State<LoanFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _borrowerNameController;
  late TextEditingController _phoneController;
  late TextEditingController _purposeController;

  DateTime? _startDate;
  DateTime? _endDate;
  bool _termsAccepted = false;

  Loan? _existingLoan;
  Item? _targetItem;

  @override
  void initState() {
    super.initState();
    _borrowerNameController = TextEditingController();
    _phoneController = TextEditingController();
    _purposeController = TextEditingController();

    _startDate = DateTime.now().add(const Duration(days: 1));
    _endDate = DateTime.now().add(const Duration(days: 4));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final store = AppScope.of(context);

    if (widget.loanId != null && _existingLoan == null) {
      _existingLoan = store.getLoanById(widget.loanId!);
      if (_existingLoan != null) {
        _borrowerNameController.text = _existingLoan!.borrowerName;
        _phoneController.text = _existingLoan!.borrowerPhone;
        _purposeController.text = _existingLoan!.purpose;
        _startDate = _existingLoan!.startDate;
        _endDate = _existingLoan!.endDate;
        _termsAccepted = _existingLoan!.termsAccepted;
        _targetItem = store.getItemById(_existingLoan!.itemId);
      }
    } else if (widget.itemId != null && _targetItem == null) {
      _targetItem = store.getItemById(widget.itemId!);
      final profile = store.userProfile;
      _borrowerNameController.text = profile.name;
      _phoneController.text = profile.phone;
    }
  }

  @override
  void dispose() {
    _borrowerNameController.dispose();
    _phoneController.dispose();
    _purposeController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final initialDate = isStart
        ? (_startDate ?? DateTime.now().add(const Duration(days: 1)))
        : (_endDate ?? DateTime.now().add(const Duration(days: 4)));

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 180)),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = _startDate!.add(const Duration(days: 3));
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final dateError = Validators.validateDates(_startDate, _endDate);
    if (dateError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(dateError), backgroundColor: Colors.red),
      );
      return;
    }

    final termsError = Validators.validateTerms(_termsAccepted);
    if (termsError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(termsError), backgroundColor: Colors.red),
      );
      return;
    }

    final store = AppScope.of(context);
    final itemId = _targetItem?.id ?? _existingLoan?.itemId;

    if (itemId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Barang tidak ditemukan'), backgroundColor: Colors.red),
      );
      return;
    }

    final newLoan = Loan(
      id: _existingLoan?.id ?? 'loan-${DateTime.now().millisecondsSinceEpoch}',
      itemId: itemId,
      borrowerName: _borrowerNameController.text.trim(),
      borrowerPhone: _phoneController.text.trim(),
      startDate: _startDate!,
      endDate: _endDate!,
      purpose: _purposeController.text.trim(),
      status: _existingLoan?.status ?? LoanStatus.menunggu,
      termsAccepted: _termsAccepted,
    );

    final success = await store.saveLoan(newLoan);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.loanId == null
                ? 'Pengajuan pinjaman berhasil dibuat!'
                : 'Pengajuan pinjaman berhasil diperbarui!'),
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan pengajuan: ${store.errorMessage}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);

    if ((widget.itemId != null || widget.loanId != null) &&
        _targetItem == null &&
        _existingLoan == null &&
        !store.isLoading) {
      return const NotFoundScreen();
    }

    final isEdit = widget.loanId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Pengajuan Pinjaman' : 'Form Pengajuan Pinjaman'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Target Item info header
              if (_targetItem != null)
                Card(
                  color: const Color(0xFF0F6E56).withOpacity(0.08),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey.shade300,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.asset(
                        _targetItem!.imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported),
                      ),
                    ),
                    title: Text(
                      _targetItem!.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('Pemilik: ${_targetItem!.ownerName} · ${_targetItem!.location}'),
                  ),
                ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _borrowerNameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Peminjam *',
                  hintText: 'Nama lengkap Anda',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (val) => Validators.validateMinLength(val, 3, 'Nama peminjam'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Nomor WhatsApp *',
                  hintText: '081234567890',
                  prefixIcon: Icon(Icons.phone),
                ),
                validator: (val) => Validators.validatePhone(val),
              ),
              const SizedBox(height: 16),
              // Dates Row
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context, true),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Tanggal Mulai *',
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          _startDate != null
                              ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                              : 'Pilih Tanggal',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context, false),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Tanggal Selesai *',
                          prefixIcon: Icon(Icons.event_available),
                        ),
                        child: Text(
                          _endDate != null
                              ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                              : 'Pilih Tanggal',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _purposeController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Tujuan Peminjaman *',
                  hintText: 'Jelaskan untuk keperluan apa Anda meminjam barang ini...',
                  prefixIcon: Icon(Icons.notes),
                ),
                validator: (val) => Validators.validateMinLength(val, 10, 'Tujuan peminjaman'),
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                value: _termsAccepted,
                onChanged: (val) => setState(() => _termsAccepted = val ?? false),
                title: const Text(
                  'Saya berjanji menjaga barang yang dipinjam dengan baik dan mengembalikannya tepat waktu.',
                  style: TextStyle(fontSize: 12),
                ),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 24),
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
                    : Text(isEdit ? 'Simpan Perubahan' : 'Kirim Pengajuan Peminjaman'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
