// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Slovak (`sk`).
class AppLocalizationsSk extends AppLocalizations {
  AppLocalizationsSk([String locale = 'sk']) : super(locale);

  @override
  String get menu => 'Menu';

  @override
  String get colorTheme => 'Nastavenia';

  @override
  String get help => 'Pomocník';

  @override
  String get helpSwiping => 'Posúvanie';

  @override
  String get helpSwipingContent =>
      'Posúvaj karty k správnemu členu. Ak si nevieš rady, podrž na karte prst pre nápovedu';

  @override
  String get helpTips => 'Tipy';

  @override
  String get helpTipsContent =>
      'Časté koncovky a kategórie, ktoré ti pomôžu určiť správny člen';

  @override
  String get helpKeyboard => 'Klávesnica';

  @override
  String get helpKeyboardContent =>
      'Ovládaj hru na PC pomocou klávesových skratiek';

  @override
  String get helpArrows => 'Šípky';

  @override
  String get helpSystem => 'Systém';

  @override
  String get helpReveal => 'Odkrytie';

  @override
  String get swipeLeft => 'Potiahni vľavo pre \"die\"';

  @override
  String get swipeUp => 'Potiahni hore pre \"das\"';

  @override
  String get swipeRight => 'Potiahni vpravo pre \"der\"';

  @override
  String get longPressHint => 'Dlho podrž pre nápovedu';

  @override
  String get level => 'Učenie';

  @override
  String get noWordsFound => 'Nenašli sa žiadne slová';

  @override
  String get openMenuTooltip => 'Otvoriť ponuku';

  @override
  String get themeLight => 'Svetlý';

  @override
  String get themeDark => 'Tmavý';

  @override
  String get themeSepia => 'Sépia';

  @override
  String get themeMidnight => 'Polnočný';

  @override
  String get themeNordic => 'Severský';

  @override
  String get themeForest => 'Lesný';

  @override
  String get themeSakura => 'Sakura';

  @override
  String get themeNeon => 'Neónový';

  @override
  String get training => 'Precvičovanie';

  @override
  String get reviewLearned => 'Opakovanie';

  @override
  String get survival => 'Prežitie';

  @override
  String get challenge => 'Súboj';

  @override
  String get weakPoints => 'Slabé miesta';

  @override
  String levelTitle(Object level) {
    return 'Úroveň $level';
  }

  @override
  String get tryAgain => 'Znova';

  @override
  String get gameOver => 'Hra skončila';

  @override
  String get endGame => 'Ukončiť hru';

  @override
  String survivalScore(Object score) {
    return 'Skóre: $score';
  }

  @override
  String get statsTitle => 'Štatistiky';

  @override
  String get currentStreak => 'Aktuálna séria';

  @override
  String get streakDays => 'dní';

  @override
  String get globalProgress => 'Celkový postup';

  @override
  String learnedStats(Object learned, Object total) {
    return '$learned naučených z $total slov';
  }

  @override
  String get hallOfFame => 'Sieň slávy';

  @override
  String get noScores => 'Zatiaľ žiadne výsledky. Hraj!';

  @override
  String get points => 'bodov';

  @override
  String get donateTitle => 'Pozvi ma na kávu';

  @override
  String get donateSubtitle => 'Podpor ďalší vývoj';

  @override
  String get menuStats => 'Štatistiky';

  @override
  String get about => 'O aplikácii';

  @override
  String get refreshStats => 'Aktualizovať';

  @override
  String get haptics => 'Vibrácie';

  @override
  String get dailyReminder => 'Denné pripomenutie';

  @override
  String get dailyReminderDesc => 'Dostávaj upozornenia na precvičovanie';

  @override
  String get powerSaving => 'Úsporný režim';

  @override
  String get powerSavingDesc => 'Stmav obrazovku pri nečinnosti';

  @override
  String get autoSpeech => 'Automatické čítanie';

  @override
  String get cardStyle => 'Štýl kariet';

  @override
  String get cardStyleModern => 'Moderný';

  @override
  String get cardStyleClassic => 'Klasický';

  @override
  String get cardStyleGothic => 'Švabach';

  @override
  String get fontSettingsTitle => 'Písmo';

  @override
  String get handsFree => 'Hlasové ovládanie';

  @override
  String get listenTooltip => 'Vypočuj si výslovnosť';

  @override
  String get dailyReminderTitle => 'Čas na nemčinu!';

  @override
  String get dailyReminderBody => 'Poď si dnes precvičiť pár slovíčok.';

  @override
  String get yes => 'Áno';

  @override
  String get no => 'Nie';

  @override
  String get back => 'Späť';

  @override
  String get tipUng => '-ung, -heit, -keit, -schaft';

  @override
  String get tipChen => '-chen, -lein, -um';

  @override
  String get tipIg => '-ig, -ling, -ismus';

  @override
  String get tipTime => 'Dni, mesiace, ročné obdobia';

  @override
  String get tipAuto => 'Značky áut a vlaky';

  @override
  String get tipForeign => 'Cudzie slová na -ma (Thema, Drama)';

  @override
  String get license => 'Licencia';

  @override
  String get keyLeft => 'Der';

  @override
  String get keyDown => 'Die';

  @override
  String get keyRight => 'Das';

  @override
  String get keyMenu => 'Menu';

  @override
  String get autoplay => 'Auto prehrávanie';

  @override
  String get continues => 'Pokračovať';

  @override
  String get levelComplete => 'Skvelá práca!';

  @override
  String get keepItUp => 'Dokončil si ďalšiu časť tréningu.\nLen tak ďalej!';

  @override
  String get backToLearning => 'Späť k učeniu';

  @override
  String get microphonePermissionError => 'Nepodarilo sa povoliť mikrofón';
}
