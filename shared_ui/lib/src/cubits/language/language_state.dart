part of 'language_cubit.dart';

class LanguageState {
  final Locale locale;
  const LanguageState(this.locale);

  String get languageCode => locale.languageCode;
}
