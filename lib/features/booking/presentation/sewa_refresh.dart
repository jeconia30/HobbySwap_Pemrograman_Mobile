import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../home/presentation/home_controller.dart';
import '../../item/data/item_providers.dart';
import '../../review/data/review_providers.dart';
import '../data/booking_providers.dart';

extension SewaRefresh on WidgetRef {
  /// Muat ulang semua daftar yang bergantung pada status sewa/ulasan, supaya
  /// Sewaan Saya, Barang Saya, Beranda, dan Detail ikut berubah.
  void refreshSewa() => this
    ..invalidate(myBookingsProvider)
    ..invalidate(ownerBookingsProvider)
    ..invalidate(bookingByIdProvider)
    ..invalidate(blockedDatesProvider)
    ..invalidate(myItemsProvider)
    ..invalidate(itemByIdProvider)
    ..invalidate(homeItemsProvider)
    ..invalidate(myReviewedBookingIdsProvider)
    ..invalidate(reviewsForUserProvider);
}
