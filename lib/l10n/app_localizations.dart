import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru')
  ];

  /// No description provided for @photo.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get photo;

  /// No description provided for @text.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get text;

  /// No description provided for @settings_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings_tooltip;

  /// No description provided for @settings_appbar_title.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings_appbar_title;

  /// No description provided for @back_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back_tooltip;

  /// No description provided for @close_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close_tooltip;

  /// No description provided for @text_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter your question here...'**
  String get text_hint;

  /// No description provided for @explain_it_button.
  ///
  /// In en, this message translates to:
  /// **'Explain it'**
  String get explain_it_button;

  /// No description provided for @the_minimum_number_error.
  ///
  /// In en, this message translates to:
  /// **'The minimum number of characters is 10'**
  String get the_minimum_number_error;

  /// No description provided for @unknown_error.
  ///
  /// In en, this message translates to:
  /// **'Unknown error'**
  String get unknown_error;

  /// No description provided for @result_page_title.
  ///
  /// In en, this message translates to:
  /// **'Your result'**
  String get result_page_title;

  /// No description provided for @explain_again_button.
  ///
  /// In en, this message translates to:
  /// **'Explain again'**
  String get explain_again_button;

  /// No description provided for @google_login.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get google_login;

  /// No description provided for @google_login_error.
  ///
  /// In en, this message translates to:
  /// **'Unknown error'**
  String get google_login_error;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Solving… this takes a few seconds'**
  String get loading;

  /// No description provided for @recognizing.
  ///
  /// In en, this message translates to:
  /// **'Recognizing the problem…'**
  String get recognizing;

  /// No description provided for @your_request.
  ///
  /// In en, this message translates to:
  /// **'Your question'**
  String get your_request;

  /// No description provided for @auth_badge.
  ///
  /// In en, this message translates to:
  /// **'AI homework mentor'**
  String get auth_badge;

  /// No description provided for @auth_title.
  ///
  /// In en, this message translates to:
  /// **'Snap a problem.\nGet a clear solution.'**
  String get auth_title;

  /// No description provided for @auth_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Point the camera at any task — the AI reads it and walks you through the answer step by step.'**
  String get auth_subtitle;

  /// No description provided for @auth_feature_photo.
  ///
  /// In en, this message translates to:
  /// **'Photo or text input'**
  String get auth_feature_photo;

  /// No description provided for @auth_feature_steps.
  ///
  /// In en, this message translates to:
  /// **'Step-by-step explanations'**
  String get auth_feature_steps;

  /// No description provided for @auth_feature_subjects.
  ///
  /// In en, this message translates to:
  /// **'Math, physics, chemistry and more'**
  String get auth_feature_subjects;

  /// No description provided for @camera_hint.
  ///
  /// In en, this message translates to:
  /// **'Fit the problem inside the frame'**
  String get camera_hint;

  /// No description provided for @flash_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Flash'**
  String get flash_tooltip;

  /// No description provided for @keyboard_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Type instead'**
  String get keyboard_tooltip;

  /// No description provided for @text_title.
  ///
  /// In en, this message translates to:
  /// **'Ask anything'**
  String get text_title;

  /// No description provided for @text_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Type a problem or a question — the AI will explain it step by step.'**
  String get text_subtitle;

  /// No description provided for @examples_title.
  ///
  /// In en, this message translates to:
  /// **'Try an example'**
  String get examples_title;

  /// No description provided for @recognized_title.
  ///
  /// In en, this message translates to:
  /// **'Check the recognized text'**
  String get recognized_title;

  /// No description provided for @solution_title.
  ///
  /// In en, this message translates to:
  /// **'Step-by-step solution'**
  String get solution_title;

  /// No description provided for @new_question.
  ///
  /// In en, this message translates to:
  /// **'New question'**
  String get new_question;

  /// No description provided for @copy_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy_tooltip;

  /// No description provided for @copied.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get copied;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
