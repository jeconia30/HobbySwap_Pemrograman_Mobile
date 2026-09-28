import 'dart:async';
import '../models.dart';
import 'seed_data.dart';

class MockRepository {
  List<HobbyCategory> _categories = List.from(SeedData.categories);
  List<Item> _items = List.from(SeedData.items);
  List<Loan> _loans = List.from(SeedData.loans);
  UserProfile _profile = SeedData.defaultProfile;

  bool failureSimulated = false;

  Future<void> _simulateNetwork() async {
    await Future.delayed(const Duration(milliseconds: 700));
    if (failureSimulated) {
      throw Exception('Simulasi kegagalan jaringan aktif. Gagal terhubung ke server.');
    }
  }

  Future<List<HobbyCategory>> fetchCategories() async {
    await _simulateNetwork();
    return List.unmodifiable(_categories);
  }

  Future<List<Item>> fetchItems() async {
    await _simulateNetwork();
    return List.unmodifiable(_items);
  }

  Future<List<Loan>> fetchLoans() async {
    await _simulateNetwork();
    return List.unmodifiable(_loans);
  }

  Future<UserProfile> fetchProfile() async {
    await _simulateNetwork();
    return _profile;
  }

  Future<Item> saveItem(Item item) async {
    await _simulateNetwork();
    final index = _items.indexWhere((i) => i.id == item.id);
    if (index >= 0) {
      _items[index] = item;
    } else {
      _items.insert(0, item);
    }
    return item;
  }

  Future<void> deleteItem(String id) async {
    await _simulateNetwork();
    _items.removeWhere((i) => i.id == id);
    _loans.removeWhere((l) => l.itemId == id);
  }

  Future<Loan> saveLoan(Loan loan) async {
    await _simulateNetwork();
    final index = _loans.indexWhere((l) => l.id == loan.id);
    if (index >= 0) {
      _loans[index] = loan;
    } else {
      _loans.insert(0, loan);
    }

    if (loan.status == LoanStatus.disetujui || loan.status == LoanStatus.menunggu) {
      final itemIndex = _items.indexWhere((i) => i.id == loan.itemId);
      if (itemIndex >= 0) {
        _items[itemIndex] = _items[itemIndex].copyWith(isAvailable: false);
      }
    }

    return loan;
  }

  Future<void> deleteLoan(String id) async {
    await _simulateNetwork();
    final loanIndex = _loans.indexWhere((l) => l.id == id);
    if (loanIndex >= 0) {
      final loan = _loans[loanIndex];
      _loans.removeAt(loanIndex);

      final hasOtherActiveLoan = _loans.any((l) =>
          l.itemId == loan.itemId &&
          (l.status == LoanStatus.menunggu || l.status == LoanStatus.disetujui));

      if (!hasOtherActiveLoan) {
        final itemIndex = _items.indexWhere((i) => i.id == loan.itemId);
        if (itemIndex >= 0) {
          _items[itemIndex] = _items[itemIndex].copyWith(isAvailable: true);
        }
      }
    }
  }

  Future<UserProfile> saveProfile(UserProfile profile) async {
    await _simulateNetwork();
    _profile = profile;
    return _profile;
  }
}
