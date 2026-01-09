// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Czech (`cs`).
class AppLocalizationsCs extends AppLocalizations {
  AppLocalizationsCs([String locale = 'cs']) : super(locale);

  @override
  String get menu => 'Menu';

  @override
  String get colorTheme => 'Nastavení';

  @override
  String get help => 'Nápověda';

  @override
  String get helpSwiping => 'Swipování';

  @override
  String get helpSwipingContent =>
      'Posouvej karty ke správnému členu. Pokud si nevíš rady, podrž na kartě prst pro nápovědu';

  @override
  String get helpTips => 'Tipy';

  @override
  String get helpTipsContent =>
      'Časté koncovky a kategorie, které ti pomohou určit správný člen';

  @override
  String get helpKeyboard => 'Klávesnice';

  @override
  String get helpKeyboardContent =>
      'Ovládni hru na PC pomocí klávesových zkratek';

  @override
  String get helpArrows => 'Šipky';

  @override
  String get helpSystem => 'Systém';

  @override
  String get helpReveal => 'Odkrytí';

  @override
  String get swipeLeft => 'Přejeď vlevo pro \"die\"';

  @override
  String get swipeUp => 'Přejeď nahoru pro \"das\"';

  @override
  String get swipeRight => 'Přejeď vpravo pro \"der\"';

  @override
  String get longPressHint => 'Dlouze podrž pro nápovědu';

  @override
  String get level => 'Učení';

  @override
  String get noWordsFound => 'Nenalezena žádná slova';

  @override
  String get openMenuTooltip => 'Otevřít nabídku';

  @override
  String get themeLight => 'Světlý';

  @override
  String get themeDark => 'Tmavý';

  @override
  String get themeSepia => 'Sépiový';

  @override
  String get themeMidnight => 'Půlnoční';

  @override
  String get themeNordic => 'Severský';

  @override
  String get themeForest => 'Lesní';

  @override
  String get themeSakura => 'Sakura';

  @override
  String get themeNeon => 'Neonový';

  @override
  String get training => 'Procvičování';

  @override
  String get reviewLearned => 'Opakování';

  @override
  String get survival => 'Časovka';

  @override
  String get challenge => 'Přetahovačka';

  @override
  String get weakPoints => 'Slabá místa';

  @override
  String levelTitle(Object level) {
    return 'Úroveň $level';
  }

  @override
  String get tryAgain => 'Znovu';

  @override
  String get gameOver => 'Hra skončila';

  @override
  String get endGame => 'Ukončit hru';

  @override
  String survivalScore(Object score) {
    return 'Skóre: $score';
  }

  @override
  String get statsTitle => 'Statistiky';

  @override
  String get currentStreak => 'Aktuální série';

  @override
  String get streakDays => 'dní';

  @override
  String get globalProgress => 'Celkový postup';

  @override
  String learnedStats(Object learned, Object total) {
    return '$learned naučených z $total slov';
  }

  @override
  String get hallOfFame => 'Síň slávy';

  @override
  String get noScores => 'Zatím žádné výsledky. Hraj!';

  @override
  String get points => 'bodů';

  @override
  String get donateTitle => 'Pozvi mě na kávu';

  @override
  String get donateSubtitle => 'Podpoř další vývoj';

  @override
  String get menuStats => 'Statistiky';

  @override
  String get about => 'O aplikaci';

  @override
  String get refreshStats => 'Aktualizovat';

  @override
  String get haptics => 'Vibrace';

  @override
  String get dailyReminder => 'Denní připomenutí';

  @override
  String get dailyReminderDesc => 'Dostávej upozornění na procvičování';

  @override
  String get powerSaving => 'Úsporný režim';

  @override
  String get powerSavingDesc => 'Ztmav obrazovku při nečinnosti';

  @override
  String get autoSpeech => 'Automatické čtení';

  @override
  String get cardStyle => 'Styl karet';

  @override
  String get cardStyleModern => 'Moderní';

  @override
  String get cardStyleClassic => 'Klasický';

  @override
  String get cardStyleGothic => 'Švabach';

  @override
  String get fontSettingsTitle => 'Písmo';

  @override
  String get handsFree => 'Hlasové ovládání';

  @override
  String get listenTooltip => 'Poslechni si výslovnost';

  @override
  String get dailyReminderTitle => 'Čas na němčinu!';

  @override
  String get dailyReminderBody => 'Pojď si dnes procvičit pár slovíček.';

  @override
  String get yes => 'Ano';

  @override
  String get no => 'Ne';

  @override
  String get back => 'Zpět';

  @override
  String get tipUng => '-ung, -heit, -keit, -schaft';

  @override
  String get tipChen => '-chen, -lein, -um';

  @override
  String get tipIg => '-ig, -ling, -ismus';

  @override
  String get tipTime => 'Dny, měsíce, roční období';

  @override
  String get tipAuto => 'Značky aut a vlaky';

  @override
  String get tipForeign => 'Cizí slova na -ma (Thema, Drama)';

  @override
  String get license => 'Licence';

  @override
  String get keyLeft => 'Der';

  @override
  String get keyDown => 'Die';

  @override
  String get keyRight => 'Das';

  @override
  String get keyMenu => 'Menu';

  @override
  String get autoplay => 'Auto přehrávání';

  @override
  String get continues => 'Pokračovat';

  @override
  String get levelComplete => 'Skvělá práce!';

  @override
  String get keepItUp => 'Dokončil jsi další část tréninku.\nJen tak dál!';

  @override
  String get backToLearning => 'Zpět k učení';

  @override
  String get microphonePermissionError => 'Nepodařilo se povolit mikrofon';
}
