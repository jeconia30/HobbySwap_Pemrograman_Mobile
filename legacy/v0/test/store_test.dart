import 'package:flutter_test/flutter_test.dart';
import 'package:hobby_swab/data/app_store.dart';
import 'package:hobby_swab/data/mock_repository.dart';
import 'package:hobby_swab/models.dart';
import 'package:hobby_swab/validators.dart';

void main() {
  group('Validators Tests', () {
    test('validateRequired works correctly', () {
      expect(Validators.validateRequired('', 'Nama'), equals('Nama tidak boleh kosong'));
      expect(Validators.validateRequired('   ', 'Nama'), equals('Nama tidak boleh kosong'));
      expect(Validators.validateRequired('Rani', 'Nama'), isNull);
    });

    test('validatePhone works correctly for valid/invalid numbers', () {
      expect(Validators.validatePhone('081234567890'), isNull);
      expect(Validators.validatePhone('12345'), equals('Format nomor WhatsApp tidak valid (contoh: 081234567890)'));
    });

    test('validateDates checks start date and duration', () {
      final now = DateTime.now();
      final tomorrow = now.add(const Duration(days: 1));
      final nextWeek = now.add(const Duration(days: 7));
      final nextMonth = now.add(const Duration(days: 40));

      expect(Validators.validateDates(tomorrow, nextWeek), isNull);
      expect(Validators.validateDates(nextWeek, tomorrow), equals('Tanggal selesai harus setelah atau sama dengan tanggal mulai'));
      expect(Validators.validateDates(tomorrow, nextMonth), equals('Durasi peminjaman maksimal 30 hari'));
    });
  });

  group('AppStore Tests', () {
    late MockRepository repo;
    late AppStore store;

    setUp(() async {
      repo = MockRepository();
      store = AppStore(repo);
      while (store.isLoading) {
        await Future.delayed(const Duration(milliseconds: 50));
      }
    });

    test('initial state loads items and categories', () {
      expect(store.categories.length, equals(5));
      expect(store.items.length, greaterThan(0));
      expect(store.loans.length, greaterThan(0));
    });

    test('filter items by category and search query', () {
      store.setSearchQuery('Sepatu');
      expect(store.filteredItems.any((i) => i.name.contains('Sepatu')), isTrue);

      store.resetFilters();
      expect(store.filteredItems.length, equals(store.items.length));
    });

    test('CRUD item in store', () async {
      const newItem = Item(
        id: 'test-item-1',
        name: 'Tes Barang',
        categoryId: 'cat-1',
        location: 'Kampus A',
        imagePath: 'assets/items/sepatu.jpg',
        description: 'Deskripsi tes barang hobi',
        ownerName: 'Rani',
        isMine: true,
      );

      final saveSuccess = await store.saveItem(newItem);
      if (!saveSuccess) print('saveItem error: ${store.errorMessage}, isSaving=${store.isSaving}');
      expect(saveSuccess, isTrue);
      expect(store.getItemById('test-item-1'), isNotNull);

      final deleteSuccess = await store.deleteItem('test-item-1');
      expect(deleteSuccess, isTrue);
      expect(store.getItemById('test-item-1'), isNull);
    });
  });
}
