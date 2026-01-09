// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get menu => 'Menü';

  @override
  String get colorTheme => 'Einstellungen';

  @override
  String get help => 'Hilfe';

  @override
  String get helpSwiping => 'Wischen';

  @override
  String get helpSwipingContent =>
      'Wische die Karten zum richtigen Artikel. Halte die Karte gedrückt für einen Hinweis';

  @override
  String get helpTips => 'Tipps';

  @override
  String get helpTipsContent =>
      'Häufige Endungen und Kategorien, die dir helfen, den richtigen Artikel zu bestimmen';

  @override
  String get helpKeyboard => 'Tastatur';

  @override
  String get helpKeyboardContent =>
      'Steuere das Spiel am PC mit Tastaturkürzeln';

  @override
  String get helpArrows => 'Pfeile';

  @override
  String get helpSystem => 'System';

  @override
  String get helpReveal => 'Aufdecken';

  @override
  String get swipeLeft => 'Nach links für „die“';

  @override
  String get swipeUp => 'Nach oben für „das“';

  @override
  String get swipeRight => 'Nach rechts für „der“';

  @override
  String get longPressHint => 'Gedrückt halten für Hilfe';

  @override
  String get level => 'Lernen';

  @override
  String get noWordsFound => 'Keine Wörter gefunden';

  @override
  String get openMenuTooltip => 'Menü öffnen';

  @override
  String get themeLight => 'Hell';

  @override
  String get themeDark => 'Dunkel';

  @override
  String get themeSepia => 'Sepia';

  @override
  String get themeMidnight => 'Mitternacht';

  @override
  String get themeNordic => 'Nordisch';

  @override
  String get themeForest => 'Wald';

  @override
  String get themeSakura => 'Sakura';

  @override
  String get themeNeon => 'Neon';

  @override
  String get training => 'Übung';

  @override
  String get reviewLearned => 'Wiederholung';

  @override
  String get survival => 'Zeitfahren';

  @override
  String get challenge => 'Tauziehen';

  @override
  String get weakPoints => 'Schwachstellen';

  @override
  String levelTitle(Object level) {
    return 'Stufe $level';
  }

  @override
  String get tryAgain => 'Nochmal';

  @override
  String get gameOver => 'Spiel vorbei';

  @override
  String get endGame => 'Beenden';

  @override
  String survivalScore(Object score) {
    return 'Punktzahl: $score';
  }

  @override
  String get statsTitle => 'Statistik';

  @override
  String get currentStreak => 'Aktuelle Serie';

  @override
  String get streakDays => 'Tage';

  @override
  String get globalProgress => 'Gesamtfortschritt';

  @override
  String learnedStats(Object learned, Object total) {
    return '$learned von $total Wörtern gelernt';
  }

  @override
  String get hallOfFame => 'Ruhmeshalle';

  @override
  String get noScores => 'Noch keine Ergebnisse. Spiel jetzt!';

  @override
  String get points => 'Punkte';

  @override
  String get donateTitle => 'Lad mich auf einen Kaffee ein';

  @override
  String get donateSubtitle => 'Entwicklung unterstützen';

  @override
  String get menuStats => 'Statistik';

  @override
  String get about => 'Über';

  @override
  String get refreshStats => 'Aktualisieren';

  @override
  String get haptics => 'Vibrationen';

  @override
  String get dailyReminder => 'Tägliche Erinnerung';

  @override
  String get dailyReminderDesc => 'Benachrichtigungen zum Üben erhalten';

  @override
  String get powerSaving => 'Energiesparmodus';

  @override
  String get powerSavingDesc => 'Bildschirm bei Inaktivität abdunkeln';

  @override
  String get autoSpeech => 'Auto-Aussprache';

  @override
  String get cardStyle => 'Kartenstil';

  @override
  String get cardStyleModern => 'Modern';

  @override
  String get cardStyleClassic => 'Klassisch';

  @override
  String get cardStyleGothic => 'Schwabacher';

  @override
  String get fontSettingsTitle => 'Schrift';

  @override
  String get handsFree => 'Sprachsteuerung';

  @override
  String get listenTooltip => 'Aussprache anhören';

  @override
  String get dailyReminderTitle => 'Zeit für Deutsch!';

  @override
  String get dailyReminderBody => 'Lass uns heute ein paar Wörter üben.';

  @override
  String get yes => 'Ja';

  @override
  String get no => 'Nein';

  @override
  String get back => 'Zurück';

  @override
  String get tipUng => '-ung, -heit, -keit, -schaft';

  @override
  String get tipChen => '-chen, -lein, -um';

  @override
  String get tipIg => '-ig, -ling, -ismus';

  @override
  String get tipTime => 'Tage, Monate, Jahreszeiten';

  @override
  String get tipAuto => 'Automarken, Züge';

  @override
  String get tipForeign => 'Fremdwörter auf -ma';

  @override
  String get license => 'Lizenz';

  @override
  String get keyLeft => 'Der';

  @override
  String get keyDown => 'Die';

  @override
  String get keyRight => 'Das';

  @override
  String get keyMenu => 'Menü';

  @override
  String get autoplay => 'Auto-Flow';

  @override
  String get continues => 'Weiter';

  @override
  String get levelComplete => 'Gute Arbeit!';

  @override
  String get keepItUp =>
      'Du hast einen weiteren Teil des Trainings abgeschlossen.\nWeiter so!';

  @override
  String get backToLearning => 'Zurück zum Lernen';

  @override
  String get microphonePermissionError =>
      'Mikrofon konnte nicht aktiviert werden';
}
