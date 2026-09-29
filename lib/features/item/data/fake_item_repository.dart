import 'package:flutter/foundation.dart';

import '../../../core/storage/session_storage.dart';
import '../../../core/utils/dates.dart';
import '../../../data/fake/fake_account_store.dart';
import '../../../data/fake/fake_booking_store.dart';
import '../../../data/fake/fake_item_store.dart';
import '../../../data/fake/sample_data.dart';
import '../../auth/domain/user.dart';
import '../../booking/domain/booking.dart';
import '../domain/item.dart';
import '../domain/item_filter.dart';
import '../domain/item_repository.dart';
import '../domain/kategori.dart';
import '../../../core/constants/app_strings.dart';

class FakeItemRepository implements ItemRepository {
  FakeItemRepository({
    required this._storage,
    required this._accounts,
    FakeItemStore? items,
    FakeBookingStore? bookings,
    DateTime Function()? now,
    this.delay = const Duration(milliseconds: 700),
  })  : _store = items ?? FakeItemStore(sampleItems),
        _bookings = bookings ?? FakeBookingStore(const []),
        _now = now ?? DateTime.now;

  static const sewaAktifMessage = 'Masih ada sewa aktif untuk barang ini';

  final SessionStorage _storage;
  final FakeAccountStore _accounts;
  final FakeItemStore _store;
  final FakeBookingStore _bookings;
  final DateTime Function() _now;
  final Duration delay;

  /// Hanya debug build: permintaan berikutnya gagal sekali (uji state error).
  bool debugFailNext = false;

  Future<void> _wait() async {
    await Future<void>.delayed(delay);
    if (kDebugMode && debugFailNext) {
      debugFailNext = false;
      throw const ItemException(AppTeks.koneksiPutus);
    }
  }

  ItemListing? _listing(Item item) {
    final owner = _accounts.byId(item.ownerId)?.user;
    if (owner == null) return null;
    final s = statusBarang(item, _bookings.all, dateOnly(_now()));
    return ItemListing(
      item: item,
      owner: owner,
      status: s.status,
      disewaSampai: s.sampai,
    );
  }

  User _owner() {
    final user = _accounts.byId(_storage.sessionUserId ?? '')?.user;
    if (user == null) throw const ItemException(AppTeks.sesiHabis);
    return user;
  }

  Item _ownedItem(String id) {
    final item = _store.byId(id);
    if (item == null) throw const ItemException('Barang ini sudah tidak ada.');
    if (item.ownerId != _owner().id) {
      throw const ItemException('Kamu hanya bisa mengubah barangmu sendiri.');
    }
    return item;
  }

  @override
  Future<List<ItemListing>> fetchItems({
    String query = '',
    Kategori? kategori,
    ItemSort sort = ItemSort.terpopuler,
    int? hargaMaks,
    bool hanyaTersedia = false,
    bool hanyaBarter = false,
  }) async {
    await _wait();
    return applyItemFilter(
      _store.all.map(_listing).nonNulls,
      ItemFilter(
        query: query,
        kategori: kategori,
        sort: sort,
        hargaMaks: hargaMaks,
        hanyaTersedia: hanyaTersedia,
        hanyaBarter: hanyaBarter,
      ),
      viewerId: _storage.sessionUserId,
    );
  }

  @override
  Future<ItemListing?> itemById(String id) async {
    await _wait();
    final item = _store.byId(id);
    return item == null ? null : _listing(item);
  }

  @override
  Future<List<ItemListing>> itemsByOwner(String userId) async {
    await _wait();
    return _store.all
        .where((i) => i.ownerId == userId)
        .map(_listing)
        .nonNulls
        .toList()
        .reversed
        .toList();
  }

  @override
  Future<Item> create(ItemInput input) async {
    await _wait();
    final owner = _owner();
    if (owner.statusVerifikasi != StatusVerifikasi.terverifikasi) {
      throw const ItemException(AppTeks.verifikasiDulu);
    }
    final item = Item(
      id: _store.nextId(),
      ownerId: owner.id,
      judul: input.judul.trim(),
      deskripsi: input.deskripsi.trim(),
      kategori: input.kategori,
      hargaPerHari: input.hargaPerHari,
      daftarFoto: input.daftarFoto,
      lokasiKampus: input.lokasiKampus.trim(),
      dendaPerHari: input.dendaPerHari,
    );
    _store.add(item);
    return item;
  }

  @override
  Future<Item> update(String id, ItemInput input) async {
    await _wait();
    return _store.update(_ownedItem(id).copyWith(
      judul: input.judul.trim(),
      deskripsi: input.deskripsi.trim(),
      kategori: input.kategori,
      hargaPerHari: input.hargaPerHari,
      daftarFoto: input.daftarFoto,
      lokasiKampus: input.lokasiKampus.trim(),
      dendaPerHari: input.dendaPerHari,
    ));
  }

  @override
  Future<void> setAktif(String id, bool aktif) async {
    await _wait();
    _store.update(_ownedItem(id).copyWith(aktif: aktif));
  }

  @override
  Future<void> delete(String id) async {
    await _wait();
    final item = _ownedItem(id);
    final masihAktif = _bookings.all.any((b) =>
        b.itemId == item.id &&
        (b.status == StatusBooking.menunggu ||
            b.status == StatusBooking.disetujui ||
            b.status == StatusBooking.berlangsung));
    if (masihAktif) throw const ItemException(sewaAktifMessage);
    _store.remove(item.id);
  }
}
