import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_ui/shared_ui.dart';
import 'core/router/app_router.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await Supabase.initialize(
    url: 'https://rysmffaweockfcunixin.supabase.co',
    anonKey: 'sb_publishable_33zzlb_xV-Y4oTvWrPOYEA_C79vCkOh',
  );

  setupServiceLocator();

  runApp(const CustomerApp());
}

class CustomerApp extends StatelessWidget {
  const CustomerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(create: (_) => AuthCubit()..init()),
        BlocProvider<UserCubit>(create: (_) => UserCubit()),
        BlocProvider<AppointmentsCubit>(create: (_) => AppointmentsCubit()),
        BlocProvider<LanguageCubit>(create: (_) => LanguageCubit()..init()),
      ],
      child: BlocBuilder<LanguageCubit, LanguageState>(
        builder: (context, langState) {
          return ScreenUtilInit(
            designSize: const Size(390, 844),
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (context, child) {
              return MaterialApp.router(
                title: 'Premium Barber',
                debugShowCheckedModeBanner: false,
                locale: langState.locale,
                supportedLocales: const [Locale('en'), Locale('ru')],
                localizationsDelegates: const [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                theme: ThemeData(
                  scaffoldBackgroundColor: AppColors.background,
                  colorScheme: const ColorScheme.dark(
                    primary: AppColors.primaryGold,
                    surface: AppColors.surface,
                  ),
                  useMaterial3: true,
                  appBarTheme: const AppBarTheme(
                    backgroundColor: AppColors.background,
                    elevation: 0,
                    iconTheme: IconThemeData(color: Colors.white),
                  ),
                ),
                routerConfig: appRouter,
                builder: (context, child) {
                  const double maxWidth = 430.0;
                  final double screenWidth = MediaQuery.of(context).size.width;
                  if (screenWidth <= maxWidth) return child!;
                  return Container(
                    color: AppColors.background,
                    child: Center(
                      child: SizedBox(
                        width: maxWidth,
                        child: MediaQuery(
                          data: MediaQuery.of(context).copyWith(
                            size: Size(maxWidth, MediaQuery.of(context).size.height),
                          ),
                          child: child!,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
