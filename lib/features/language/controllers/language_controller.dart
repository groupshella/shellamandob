import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/features/language/domain/models/language_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/language/domain/service/language_service_interface.dart';

class LocalizationController extends GetxController implements GetxService {
  final LanguageServiceInterface languageServiceInterface;
  LocalizationController({required this.languageServiceInterface}) {
    loadCurrentLanguage();
  }

  Locale _locale = Locale(AppConstants.languages[0].languageCode!,
      AppConstants.languages[0].countryCode);
  Locale get locale => _locale;

  bool _isLtr = true;
  bool get isLtr => _isLtr;

  List<LanguageModel> _languages = [];
  List<LanguageModel> get languages => _languages;

  int _selectedLanguageIndex = 0;
  int get selectedLanguageIndex => _selectedLanguageIndex;

  void setLanguage(context, Locale locale, {bool fromBottomSheet = false}) {
    Get.updateLocale(locale);
    _locale = locale;
    _isLtr = languageServiceInterface.setLTR(_locale);
    languageServiceInterface.updateHeader(
        _locale, Get.find<SplashController>().module?.id);

    if (!fromBottomSheet) {
      saveLanguage(_locale);
    }


    update();
    update(['app_locale']);
  }

  void loadCurrentLanguage() async {
    _locale = languageServiceInterface.getLocaleFromSharedPref();
    _isLtr = _locale.languageCode != 'ar';
    _selectedLanguageIndex = (languageServiceInterface.setSelectedIndex(
        AppConstants.languages, _locale) as int?) ?? 0;
    _languages = [];
    _languages.addAll(AppConstants.languages);
    update();
  }

  void saveLanguage(Locale locale) async {
    languageServiceInterface.saveLanguage(locale);
  }

  void saveCacheLanguage(Locale? locale) {
    languageServiceInterface.saveCacheLanguage(
        locale ?? languageServiceInterface.getLocaleFromSharedPref());
  }

  void setSelectLanguageIndex(int index) {
    _selectedLanguageIndex = index;
    update();
  }

  Locale getCacheLocaleFromSharedPref() {
    return languageServiceInterface.getCacheLocaleFromSharedPref();
  }

  void searchSelectedLanguage() {
    for (final language in AppConstants.languages) {
      if (language.languageCode!
          .toLowerCase()
          .contains(_locale.languageCode.toLowerCase())) {
        _selectedLanguageIndex = AppConstants.languages.indexOf(language);
      }
    }
  }
}
