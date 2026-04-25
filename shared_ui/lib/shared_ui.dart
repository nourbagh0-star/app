// Theme
export 'src/theme/app_colors.dart';
export 'src/theme/app_typography.dart';

// Widgets
export 'src/widgets/primary_button.dart';
export 'src/widgets/premium_image.dart';
export 'src/widgets/login_screen.dart';
export 'src/widgets/signup_screen.dart';
export 'src/widgets/forgot_password_screen.dart';

// Backend (legacy services)
export 'src/backend/auth_service.dart';
export 'src/backend/database_service.dart';
export 'src/backend/storage_service.dart';
export 'src/backend/go_router_refresh_stream.dart';

// Models
export 'src/models/models.dart';
export 'src/models/user_model.dart';
export 'src/models/shop_model.dart';
export 'src/models/booking_model.dart';

// Repositories
export 'src/repositories/auth_repository.dart';
export 'src/repositories/shop_repository.dart';
export 'src/repositories/booking_repository.dart';
export 'src/repositories/storage_repository.dart';

// Dependency Injection
export 'src/di/service_locator.dart';

// Cubits
export 'src/cubits/auth/auth_cubit.dart';
export 'src/cubits/user/user_cubit.dart';
export 'src/cubits/appointments/appointments_cubit.dart';
export 'src/cubits/shop/shop_cubit.dart';
export 'src/cubits/barber_schedule/barber_schedule_cubit.dart';
export 'src/cubits/language/language_cubit.dart';

// Localisation
export 'src/l10n/app_strings.dart';

// Dummy data (kept for seeding utility)
export 'src/dummy_data/dummy_data.dart';
