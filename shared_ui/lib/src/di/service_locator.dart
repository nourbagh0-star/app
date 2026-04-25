import 'package:get_it/get_it.dart';
import '../repositories/auth_repository.dart';
import '../repositories/shop_repository.dart';
import '../repositories/booking_repository.dart';
import '../repositories/storage_repository.dart';
import '../backend/auth_service.dart';
import '../backend/database_service.dart';
import '../backend/storage_service.dart';

final GetIt sl = GetIt.instance;

void setupServiceLocator() {
  // ── Legacy services (kept for backward-compat) ───────────────────
  sl.registerLazySingleton<AuthService>(() => AuthService());
  sl.registerLazySingleton<DatabaseService>(() => DatabaseService());
  sl.registerLazySingleton<StorageService>(() => StorageService());

  // ── Repositories ─────────────────────────────────────────────────
  sl.registerLazySingleton<AuthRepository>(() => AuthRepository());
  sl.registerLazySingleton<ShopRepository>(() => ShopRepository());
  sl.registerLazySingleton<BookingRepository>(() => BookingRepository());
  sl.registerLazySingleton<StorageRepository>(() => StorageRepository());
}
