import 'package:flutter/foundation.dart';
import '../models.dart';
import 'mock_repository.dart';

class AppStore extends ChangeNotifier {
  final MockRepository repository;

  AppStore(this.repository) {
    fetchData();
  }

  List<HobbyCategory> _categories = [];
  List<Item> _items = [];
  List<Loan> _loans = [];
  UserProfile? _userProfile;

  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;

  bool _darkMode = false;
  bool _failureSimulated = false;

  // Filter states
  String _searchQuery = '';
  String? _selectedCategoryId;
  bool _onlyAvailable = false;

  // Getters
  List<HobbyCategory> get categories => List.unmodifiable(_categories);
  List<Item> get items => List.unmodifiable(_items);
  List<Loan> get loans => List.unmodifiable(_loans);
  UserProfile get userProfile => _userProfile ?? const UserProfile(
        name: 'Rani Putri',
        email: 'rani@mahasiswa.ac.id',
        phone: '081234567890',
        campus: 'Kampus A',
        bio: 'Mahasiswi Rantau',
      );

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  bool get darkMode => _darkMode;
  bool get failureSimulated => _failureSimulated;

  String get searchQuery => _searchQuery;
  String? get selectedCategoryId => _selectedCategoryId;
  bool get onlyAvailable => _onlyAvailable;

  List<Item> get filteredItems {
    return _items.where((item) {
      if (_selectedCategoryId != null && _selectedCategoryId!.isNotEmpty) {
        if (item.categoryId != _selectedCategoryId) return false;
      }
      if (_onlyAvailable && !item.isAvailable) return false;

      if (_searchQuery.trim().isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchName = item.name.toLowerCase().contains(query);
        final matchLoc = item.location.toLowerCase().contains(query);
        final matchDesc = item.description.toLowerCase().contains(query);
        if (!matchName && !matchLoc && !matchDesc) return false;
      }

      return true;
    }).toList();
  }

  List<Item> get myItems => _items.where((item) => item.isMine).toList();

  List<Loan> get myLoans => _loans;

  int countLoansByStatus(LoanStatus status) {
    return _loans.where((l) => l.status == status).length;
  }

  Item? getItemById(String id) {
    try {
      return _items.firstWhere((i) => i.id == id);
    } catch (_) {
      return null;
    }
  }

  Loan? getLoanById(String id) {
    try {
      return _loans.firstWhere((l) => l.id == id);
    } catch (_) {
      return null;
    }
  }

  HobbyCategory? getCategoryById(String id) {
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedCategory(String? categoryId) {
    _selectedCategoryId = categoryId;
    notifyListeners();
  }

  void setOnlyAvailable(bool val) {
    _onlyAvailable = val;
    notifyListeners();
  }

  void resetFilters() {
    _searchQuery = '';
    _selectedCategoryId = null;
    _onlyAvailable = false;
    notifyListeners();
  }

  void toggleDarkMode() {
    _darkMode = !_darkMode;
    notifyListeners();
  }

  void toggleFailureSimulation() {
    _failureSimulated = !_failureSimulated;
    repository.failureSimulated = _failureSimulated;
    notifyListeners();
  }

  Future<void> fetchData({bool forceReload = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _categories = List.from(await repository.fetchCategories());
      _items = List.from(await repository.fetchItems());
      _loans = List.from(await repository.fetchLoans());
      _userProfile = await repository.fetchProfile();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveItem(Item item) async {
    if (_isSaving) return false;
    _isSaving = true;
    notifyListeners();

    try {
      final saved = await repository.saveItem(item);
      final index = _items.indexWhere((i) => i.id == saved.id);
      if (index >= 0) {
        _items[index] = saved;
      } else {
        _items.insert(0, saved);
      }
      _isSaving = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteItem(String id) async {
    if (_isSaving) return false;
    _isSaving = true;
    notifyListeners();

    try {
      await repository.deleteItem(id);
      _items.removeWhere((i) => i.id == id);
      _loans.removeWhere((l) => l.itemId == id);
      _isSaving = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> saveLoan(Loan loan) async {
    if (_isSaving) return false;
    _isSaving = true;
    notifyListeners();

    try {
      final saved = await repository.saveLoan(loan);
      final index = _loans.indexWhere((l) => l.id == saved.id);
      if (index >= 0) {
        _loans[index] = saved;
      } else {
        _loans.insert(0, saved);
      }

      _items = List.from(await repository.fetchItems());

      _isSaving = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteLoan(String id) async {
    if (_isSaving) return false;
    _isSaving = true;
    notifyListeners();

    try {
      await repository.deleteLoan(id);
      _loans.removeWhere((l) => l.id == id);
      _items = List.from(await repository.fetchItems());
      _isSaving = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProfile(UserProfile profile) async {
    if (_isSaving) return false;
    _isSaving = true;
    notifyListeners();

    try {
      _userProfile = await repository.saveProfile(profile);
      _isSaving = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }
}
