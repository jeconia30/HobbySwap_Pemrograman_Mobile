import 'package:flutter_test/flutter_test.dart';
import 'package:hobby_swab/data/fake/fake_account_store.dart';
import 'package:hobby_swab/data/fake/sample_data.dart';
import 'package:hobby_swab/features/booking/domain/booking.dart';
import 'package:hobby_swab/features/item/domain/item.dart';
import 'package:hobby_swab/features/item/domain/item_filter.dart';
import 'package:hobby_swab/features/item/domain/kategori.dart';

const gregorian = 'usr-001';

void main() {
  final accounts = FakeAccountStore();
  final today = DateTime(2026, 10, 5);
  final bookings = sampleBookingsFor(today);
  final all = [
    for (final item in sampleItemsFor(today))
      () {
        final s = statusBarang(item, bookings, today);
        return ItemListing(
          item: item,
          owner: accounts.byId(item.ownerId)!.user,
          status: s.status,
          disewaSampai: s.sampai,
        );
      }(),
  ];

  test('status turunan: Sepatu disewa, Hammock nonaktif, lainnya tersedia',
      () {
    ItemStatus of(String judul) =>
        all.firstWhere((l) => l.item.judul == judul).status;
    expect(of('Sepatu Futsal Specs ukuran 42'), ItemStatus.disewa);
    expect(of('Nintendo Switch OLED'), ItemStatus.disewa);
    expect(of('Hammock ENO Single'), ItemStatus.nonaktif);
    expect(of('Sony A6400 + Lensa Kit 16–50mm'), ItemStatus.disewa,
        reason: 'sedang disewa Gregorian h-1..h+1');
    expect(of('Canon EOS M50 Mark II'), ItemStatus.tersedia);
  });

  List<String> titles(ItemFilter f, {String? viewer = gregorian}) =>
      applyItemFilter(all, f, viewerId: viewer).map((l) => l.item.judul).toList();

  test('barang nonaktif tidak tampil di Beranda', () {
    expect(titles(const ItemFilter(), viewer: 'usr-003'),
        isNot(contains('Hammock ENO Single')));
  });

  test('barang milik user yang sedang login tidak ikut', () {
    final result = applyItemFilter(all, const ItemFilter(), viewerId: gregorian);
    expect(result, hasLength(12));
    expect(result.any((l) => l.item.ownerId == gregorian), isFalse);
    expect(applyItemFilter(all, const ItemFilter()), hasLength(15),
        reason: 'tanpa viewer semua barang aktif tampil');
  });

  test('pencarian tidak peka huruf besar/kecil', () {
    expect(titles(const ItemFilter(query: 'sony')),
        ['Sony A6400 + Lensa Kit 16–50mm']);
    expect(titles(const ItemFilter(query: '  NINTENDO ')),
        ['Nintendo Switch Lite']);
    expect(titles(const ItemFilter(query: 'KaMeRa')), hasLength(3),
        reason: 'cocok dengan label kategori');
    expect(titles(const ItemFilter(query: 'sepeda')), isEmpty);
  });

  test('filter kategori', () {
    final kamera = applyItemFilter(
        all, const ItemFilter(kategori: Kategori.kamera),
        viewerId: gregorian);
    expect(kamera, hasLength(3));
    expect(kamera.every((l) => l.item.kategori == Kategori.kamera), isTrue);
    expect(titles(const ItemFilter(kategori: Kategori.lainnya)), isEmpty);
  });

  test('urutan terpopuler (jumlahDisewa menurun)', () {
    final r = applyItemFilter(all, const ItemFilter(), viewerId: gregorian);
    expect(r.first.item.judul, 'Sony A6400 + Lensa Kit 16–50mm');
    for (var i = 1; i < r.length; i++) {
      expect(r[i - 1].item.jumlahDisewa,
          greaterThanOrEqualTo(r[i].item.jumlahDisewa));
    }
  });

  test('urutan termurah (harga naik, seri → lebih populer dulu)', () {
    final r = applyItemFilter(
        all, const ItemFilter(sort: ItemSort.termurah),
        viewerId: gregorian);
    for (var i = 1; i < r.length; i++) {
      expect(r[i - 1].item.hargaPerHari,
          lessThanOrEqualTo(r[i].item.hargaPerHari));
    }
    expect(r.take(2).map((l) => l.item.judul),
        ['Ukulele Soprano Mahoni', 'Sepatu Futsal Specs ukuran 42'],
        reason: 'sama-sama 12rb; Ukulele disewa 8× vs Sepatu 6×');
  });

  test('urutan rating tertinggi (rating pemilik)', () {
    final r = applyItemFilter(
        all, const ItemFilter(sort: ItemSort.ratingTertinggi),
        viewerId: gregorian);
    for (var i = 1; i < r.length; i++) {
      expect(r[i - 1].owner.rating, greaterThanOrEqualTo(r[i].owner.rating));
    }
    expect(r.first.owner.nama, 'Rizky Nugraha');
    expect(r.last.owner.nama, 'Aulia Putri');
  });

  test('harga maksimal (inklusif)', () {
    final r = applyItemFilter(
        all, const ItemFilter(hargaMaks: 15000),
        viewerId: gregorian);
    expect(r.map((l) => l.item.judul), unorderedEquals([
      'Kompor Portable + Nesting',
      'Raket Li-Ning Axforce 80',
      'Sepatu Futsal Specs ukuran 42',
      'Stik PS5 DualSense',
      'Ukulele Soprano Mahoni',
    ]));
    expect(r.every((l) => l.item.hargaPerHari <= 15000), isTrue);
  });

  test('hanya yang tersedia', () {
    expect(titles(const ItemFilter()), contains('Sepatu Futsal Specs ukuran 42'));
    expect(titles(const ItemFilter(hanyaTersedia: true)),
        isNot(contains('Sepatu Futsal Specs ukuran 42')));
  });

  test('filter bisa digabung', () {
    expect(
      titles(const ItemFilter(
        kategori: Kategori.olahraga,
        hanyaTersedia: true,
        hargaMaks: 15000,
      )),
      ['Raket Li-Ning Axforce 80'],
    );
  });

  test('jumlah filter sheet & status aktif', () {
    expect(const ItemFilter().isActive, isFalse);
    expect(const ItemFilter().sheetFilterCount, 0);
    expect(const ItemFilter(query: '  ').isActive, isFalse);
    expect(const ItemFilter(kategori: Kategori.game).isActive, isTrue);
    expect(const ItemFilter(kategori: Kategori.game).sheetFilterCount, 0);
    expect(
      const ItemFilter(
        sort: ItemSort.termurah,
        hargaMaks: 20000,
        hanyaTersedia: true,
      ).sheetFilterCount,
      3,
    );
  });
}
