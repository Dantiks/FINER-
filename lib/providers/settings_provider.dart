import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/country.dart';

/// App-wide settings: the user's primary country (drives default currency,
/// which tax regime is shown first, and legal reference content), plus
/// whether onboarding has been completed.
class SettingsProvider extends ChangeNotifier {
  static const _countryKey = 'primary_country';
  static const _onboardingKey = 'onboarding_done';

  AppCountry _primaryCountry = AppCountry.kg;
  bool _onboardingDone = false;
  bool _loaded = false;

  AppCountry get primaryCountry => _primaryCountry;
  bool get onboardingDone => _onboardingDone;
  bool get isLoaded => _loaded;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _primaryCountry = AppCountry.fromCode(prefs.getString(_countryKey));
    _onboardingDone = prefs.getBool(_onboardingKey) ?? false;
    _loaded = true;
    notifyListeners();
  }

  Future<void> setPrimaryCountry(AppCountry country) async {
    _primaryCountry = country;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_countryKey, country.code);
  }

  Future<void> completeOnboarding(AppCountry country) async {
    _primaryCountry = country;
    _onboardingDone = true;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_countryKey, country.code);
    await prefs.setBool(_onboardingKey, true);
  }
}
