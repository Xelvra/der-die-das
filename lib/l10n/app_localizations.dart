import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_cs.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_sk.dart';

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
    Locale('cs'),
    Locale('de'),
    Locale('en'),
    Locale('ru'),
    Locale('sk')
  ];

  /// No description provided for @menu.
  ///
  /// In cs, this message translates to:
  /// **'Menu'**
  String get menu;

  /// No description provided for @colorTheme.
  ///
  /// In cs, this message translates to:
  /// **'Nastavení'**
  String get colorTheme;

  /// No description provided for @help.
  ///
  /// In cs, this message translates to:
  /// **'Nápověda'**
  String get help;

  /// No description provided for @helpSwiping.
  ///
  /// In cs, this message translates to:
  /// **'Swipování'**
  String get helpSwiping;

  /// No description provided for @helpSwipingContent.
  ///
  /// In cs, this message translates to:
  /// **'Posouvej karty ke správnému členu. Pokud si nevíš rady, podrž na kartě prst pro nápovědu'**
  String get helpSwipingContent;

  /// No description provided for @helpTips.
  ///
  /// In cs, this message translates to:
  /// **'Tipy'**
  String get helpTips;

  /// No description provided for @helpTipsContent.
  ///
  /// In cs, this message translates to:
  /// **'Časté koncovky a kategorie, které ti pomohou určit správný člen'**
  String get helpTipsContent;

  /// No description provided for @helpKeyboard.
  ///
  /// In cs, this message translates to:
  /// **'Klávesnice'**
  String get helpKeyboard;

  /// No description provided for @helpKeyboardContent.
  ///
  /// In cs, this message translates to:
  /// **'Ovládni hru na PC pomocí klávesových zkratek'**
  String get helpKeyboardContent;

  /// No description provided for @helpArrows.
  ///
  /// In cs, this message translates to:
  /// **'Šipky'**
  String get helpArrows;

  /// No description provided for @helpSystem.
  ///
  /// In cs, this message translates to:
  /// **'Systém'**
  String get helpSystem;

  /// No description provided for @helpReveal.
  ///
  /// In cs, this message translates to:
  /// **'Odkrytí'**
  String get helpReveal;

  /// No description provided for @swipeLeft.
  ///
  /// In cs, this message translates to:
  /// **'Přejeď vlevo pro \"die\"'**
  String get swipeLeft;

  /// No description provided for @swipeUp.
  ///
  /// In cs, this message translates to:
  /// **'Přejeď nahoru pro \"das\"'**
  String get swipeUp;

  /// No description provided for @swipeRight.
  ///
  /// In cs, this message translates to:
  /// **'Přejeď vpravo pro \"der\"'**
  String get swipeRight;

  /// No description provided for @longPressHint.
  ///
  /// In cs, this message translates to:
  /// **'Dlouze podrž pro nápovědu'**
  String get longPressHint;

  /// No description provided for @level.
  ///
  /// In cs, this message translates to:
  /// **'Učení'**
  String get level;

  /// No description provided for @noWordsFound.
  ///
  /// In cs, this message translates to:
  /// **'Nenalezena žádná slova'**
  String get noWordsFound;

  /// No description provided for @openMenuTooltip.
  ///
  /// In cs, this message translates to:
  /// **'Otevřít nabídku'**
  String get openMenuTooltip;

  /// No description provided for @themeLight.
  ///
  /// In cs, this message translates to:
  /// **'Světlý'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In cs, this message translates to:
  /// **'Tmavý'**
  String get themeDark;

  /// No description provided for @themeSepia.
  ///
  /// In cs, this message translates to:
  /// **'Sépiový'**
  String get themeSepia;

  /// No description provided for @themeMidnight.
  ///
  /// In cs, this message translates to:
  /// **'Půlnoční'**
  String get themeMidnight;

  /// No description provided for @themeNordic.
  ///
  /// In cs, this message translates to:
  /// **'Severský'**
  String get themeNordic;

  /// No description provided for @themeForest.
  ///
  /// In cs, this message translates to:
  /// **'Lesní'**
  String get themeForest;

  /// No description provided for @themeSakura.
  ///
  /// In cs, this message translates to:
  /// **'Sakura'**
  String get themeSakura;

  /// No description provided for @themeNeon.
  ///
  /// In cs, this message translates to:
  /// **'Neonový'**
  String get themeNeon;

  /// No description provided for @training.
  ///
  /// In cs, this message translates to:
  /// **'Procvičování'**
  String get training;

  /// No description provided for @reviewLearned.
  ///
  /// In cs, this message translates to:
  /// **'Opakování'**
  String get reviewLearned;

  /// No description provided for @survival.
  ///
  /// In cs, this message translates to:
  /// **'Časovka'**
  String get survival;

  /// No description provided for @challenge.
  ///
  /// In cs, this message translates to:
  /// **'Přetahovačka'**
  String get challenge;

  /// No description provided for @weakPoints.
  ///
  /// In cs, this message translates to:
  /// **'Slabá místa'**
  String get weakPoints;

  /// No description provided for @levelTitle.
  ///
  /// In cs, this message translates to:
  /// **'Úroveň {level}'**
  String levelTitle(Object level);

  /// No description provided for @tryAgain.
  ///
  /// In cs, this message translates to:
  /// **'Znovu'**
  String get tryAgain;

  /// No description provided for @gameOver.
  ///
  /// In cs, this message translates to:
  /// **'Hra skončila'**
  String get gameOver;

  /// No description provided for @endGame.
  ///
  /// In cs, this message translates to:
  /// **'Ukončit hru'**
  String get endGame;

  /// No description provided for @survivalScore.
  ///
  /// In cs, this message translates to:
  /// **'Skóre: {score}'**
  String survivalScore(Object score);

  /// No description provided for @statsTitle.
  ///
  /// In cs, this message translates to:
  /// **'Statistiky'**
  String get statsTitle;

  /// No description provided for @currentStreak.
  ///
  /// In cs, this message translates to:
  /// **'Aktuální série'**
  String get currentStreak;

  /// No description provided for @streakDays.
  ///
  /// In cs, this message translates to:
  /// **'dní'**
  String get streakDays;

  /// No description provided for @globalProgress.
  ///
  /// In cs, this message translates to:
  /// **'Celkový postup'**
  String get globalProgress;

  /// No description provided for @learnedStats.
  ///
  /// In cs, this message translates to:
  /// **'{learned} naučených z {total} slov'**
  String learnedStats(Object learned, Object total);

  /// No description provided for @hallOfFame.
  ///
  /// In cs, this message translates to:
  /// **'Síň slávy'**
  String get hallOfFame;

  /// No description provided for @noScores.
  ///
  /// In cs, this message translates to:
  /// **'Zatím žádné výsledky. Hraj!'**
  String get noScores;

  /// No description provided for @points.
  ///
  /// In cs, this message translates to:
  /// **'bodů'**
  String get points;

  /// No description provided for @donateTitle.
  ///
  /// In cs, this message translates to:
  /// **'Pozvi mě na kávu'**
  String get donateTitle;

  /// No description provided for @donateSubtitle.
  ///
  /// In cs, this message translates to:
  /// **'Podpoř další vývoj'**
  String get donateSubtitle;

  /// No description provided for @menuStats.
  ///
  /// In cs, this message translates to:
  /// **'Statistiky'**
  String get menuStats;

  /// No description provided for @about.
  ///
  /// In cs, this message translates to:
  /// **'O aplikaci'**
  String get about;

  /// No description provided for @refreshStats.
  ///
  /// In cs, this message translates to:
  /// **'Aktualizovat'**
  String get refreshStats;

  /// No description provided for @haptics.
  ///
  /// In cs, this message translates to:
  /// **'Vibrace'**
  String get haptics;

  /// No description provided for @dailyReminder.
  ///
  /// In cs, this message translates to:
  /// **'Denní připomenutí'**
  String get dailyReminder;

  /// No description provided for @dailyReminderDesc.
  ///
  /// In cs, this message translates to:
  /// **'Dostávej upozornění na procvičování'**
  String get dailyReminderDesc;

  /// No description provided for @powerSaving.
  ///
  /// In cs, this message translates to:
  /// **'Úsporný režim'**
  String get powerSaving;

  /// No description provided for @powerSavingDesc.
  ///
  /// In cs, this message translates to:
  /// **'Ztmav obrazovku při nečinnosti'**
  String get powerSavingDesc;

  /// No description provided for @autoSpeech.
  ///
  /// In cs, this message translates to:
  /// **'Automatické čtení'**
  String get autoSpeech;

  /// No description provided for @cardStyle.
  ///
  /// In cs, this message translates to:
  /// **'Styl karet'**
  String get cardStyle;

  /// No description provided for @cardStyleModern.
  ///
  /// In cs, this message translates to:
  /// **'Moderní'**
  String get cardStyleModern;

  /// No description provided for @cardStyleClassic.
  ///
  /// In cs, this message translates to:
  /// **'Klasický'**
  String get cardStyleClassic;

  /// No description provided for @cardStyleGothic.
  ///
  /// In cs, this message translates to:
  /// **'Švabach'**
  String get cardStyleGothic;

  /// No description provided for @fontSettingsTitle.
  ///
  /// In cs, this message translates to:
  /// **'Písmo'**
  String get fontSettingsTitle;

  /// No description provided for @handsFree.
  ///
  /// In cs, this message translates to:
  /// **'Hlasové ovládání'**
  String get handsFree;

  /// No description provided for @listenTooltip.
  ///
  /// In cs, this message translates to:
  /// **'Poslechni si výslovnost'**
  String get listenTooltip;

  /// No description provided for @dailyReminderTitle.
  ///
  /// In cs, this message translates to:
  /// **'Čas na němčinu!'**
  String get dailyReminderTitle;

  /// No description provided for @dailyReminderBody.
  ///
  /// In cs, this message translates to:
  /// **'Pojď si dnes procvičit pár slovíček.'**
  String get dailyReminderBody;

  /// No description provided for @yes.
  ///
  /// In cs, this message translates to:
  /// **'Ano'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In cs, this message translates to:
  /// **'Ne'**
  String get no;

  /// No description provided for @back.
  ///
  /// In cs, this message translates to:
  /// **'Zpět'**
  String get back;

  /// No description provided for @tipUng.
  ///
  /// In cs, this message translates to:
  /// **'-ung, -heit, -keit, -schaft'**
  String get tipUng;

  /// No description provided for @tipChen.
  ///
  /// In cs, this message translates to:
  /// **'-chen, -lein, -um'**
  String get tipChen;

  /// No description provided for @tipIg.
  ///
  /// In cs, this message translates to:
  /// **'-ig, -ling, -ismus'**
  String get tipIg;

  /// No description provided for @tipTime.
  ///
  /// In cs, this message translates to:
  /// **'Dny, měsíce, roční období'**
  String get tipTime;

  /// No description provided for @tipAuto.
  ///
  /// In cs, this message translates to:
  /// **'Značky aut a vlaky'**
  String get tipAuto;

  /// No description provided for @tipForeign.
  ///
  /// In cs, this message translates to:
  /// **'Cizí slova na -ma (Thema, Drama)'**
  String get tipForeign;

  /// No description provided for @license.
  ///
  /// In cs, this message translates to:
  /// **'Licence'**
  String get license;

  /// No description provided for @keyLeft.
  ///
  /// In cs, this message translates to:
  /// **'Der'**
  String get keyLeft;

  /// No description provided for @keyDown.
  ///
  /// In cs, this message translates to:
  /// **'Die'**
  String get keyDown;

  /// No description provided for @keyRight.
  ///
  /// In cs, this message translates to:
  /// **'Das'**
  String get keyRight;

  /// No description provided for @keyMenu.
  ///
  /// In cs, this message translates to:
  /// **'Menu'**
  String get keyMenu;

  /// No description provided for @autoplay.
  ///
  /// In cs, this message translates to:
  /// **'Auto přehrávání'**
  String get autoplay;

  /// No description provided for @continues.
  ///
  /// In cs, this message translates to:
  /// **'Pokračovat'**
  String get continues;

  /// No description provided for @levelComplete.
  ///
  /// In cs, this message translates to:
  /// **'Skvělá práce!'**
  String get levelComplete;

  /// No description provided for @keepItUp.
  ///
  /// In cs, this message translates to:
  /// **'Dokončil jsi další část tréninku.\nJen tak dál!'**
  String get keepItUp;

  /// No description provided for @backToLearning.
  ///
  /// In cs, this message translates to:
  /// **'Zpět k učení'**
  String get backToLearning;

  /// No description provided for @microphonePermissionError.
  ///
  /// In cs, this message translates to:
  /// **'Nepodařilo se povolit mikrofon'**
  String get microphonePermissionError;
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
      <String>['cs', 'de', 'en', 'ru', 'sk'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'cs':
      return AppLocalizationsCs();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
    case 'sk':
      return AppLocalizationsSk();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
