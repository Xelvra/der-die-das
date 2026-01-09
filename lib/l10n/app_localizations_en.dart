// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get menu => 'Menu';

  @override
  String get colorTheme => 'Settings';

  @override
  String get help => 'Help';

  @override
  String get helpSwiping => 'Swiping';

  @override
  String get helpSwipingContent =>
      'Swipe cards to the correct article. You can also touch and hold the card to show a hint';

  @override
  String get helpTips => 'Tips';

  @override
  String get helpTipsContent =>
      'Common suffixes and categories that help you identify the correct article';

  @override
  String get helpKeyboard => 'Keyboard';

  @override
  String get helpKeyboardContent =>
      'Master the game on PC with keyboard shortcuts';

  @override
  String get helpArrows => 'Arrows';

  @override
  String get helpSystem => 'System';

  @override
  String get helpReveal => 'Reveal';

  @override
  String get swipeLeft => 'Swipe left for \"die\"';

  @override
  String get swipeUp => 'Swipe up for \"das\"';

  @override
  String get swipeRight => 'Swipe right for \"der\"';

  @override
  String get longPressHint => 'Long press for help';

  @override
  String get level => 'Learning';

  @override
  String get noWordsFound => 'No Words Found';

  @override
  String get openMenuTooltip => 'Open Menu';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSepia => 'Sepia';

  @override
  String get themeMidnight => 'Midnight';

  @override
  String get themeNordic => 'Nordic';

  @override
  String get themeForest => 'Forest';

  @override
  String get themeSakura => 'Sakura';

  @override
  String get themeNeon => 'Neon';

  @override
  String get training => 'Training';

  @override
  String get reviewLearned => 'Review';

  @override
  String get survival => 'Time Trial';

  @override
  String get challenge => 'Tug-of-War';

  @override
  String get weakPoints => 'Weak Points';

  @override
  String levelTitle(Object level) {
    return 'Level $level';
  }

  @override
  String get tryAgain => 'Retry';

  @override
  String get gameOver => 'Game Over';

  @override
  String get endGame => 'End Game';

  @override
  String survivalScore(Object score) {
    return 'Score: $score';
  }

  @override
  String get statsTitle => 'Stats';

  @override
  String get currentStreak => 'Current Streak';

  @override
  String get streakDays => 'days';

  @override
  String get globalProgress => 'Global Progress';

  @override
  String learnedStats(Object learned, Object total) {
    return '$learned learned of $total words';
  }

  @override
  String get hallOfFame => 'Hall of Fame';

  @override
  String get noScores => 'No results yet. Play now!';

  @override
  String get points => 'points';

  @override
  String get donateTitle => 'Buy Me a Coffee';

  @override
  String get donateSubtitle => 'Support Development';

  @override
  String get menuStats => 'Stats';

  @override
  String get about => 'About';

  @override
  String get refreshStats => 'Refresh';

  @override
  String get haptics => 'Vibrations';

  @override
  String get dailyReminder => 'Daily Reminder';

  @override
  String get dailyReminderDesc => 'Receive practice notifications';

  @override
  String get powerSaving => 'Power Saving Mode';

  @override
  String get powerSavingDesc => 'Dim screen during inactivity';

  @override
  String get autoSpeech => 'Auto Pronunciation';

  @override
  String get cardStyle => 'Card Style';

  @override
  String get cardStyleModern => 'Modern';

  @override
  String get cardStyleClassic => 'Classic';

  @override
  String get cardStyleGothic => 'Gothic';

  @override
  String get fontSettingsTitle => 'Font';

  @override
  String get handsFree => 'Voice Control';

  @override
  String get listenTooltip => 'Listen to pronunciation';

  @override
  String get dailyReminderTitle => 'Time for German!';

  @override
  String get dailyReminderBody => 'Let\'s practice some words today.';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get back => 'Back';

  @override
  String get tipUng => '-ung, -heit, -keit, -schaft';

  @override
  String get tipChen => '-chen, -lein, -um';

  @override
  String get tipIg => '-ig, -ling, -ismus';

  @override
  String get tipTime => 'Days, months, seasons';

  @override
  String get tipAuto => 'Car brands, trains';

  @override
  String get tipForeign => 'Foreign words ending in -ma';

  @override
  String get license => 'License';

  @override
  String get keyLeft => 'Der';

  @override
  String get keyDown => 'Die';

  @override
  String get keyRight => 'Das';

  @override
  String get keyMenu => 'Menu';

  @override
  String get autoplay => 'Auto Flow';

  @override
  String get continues => 'Continue';

  @override
  String get levelComplete => 'Great Job!';

  @override
  String get keepItUp =>
      'You\'ve completed another part of the training.\nKeep it up!';

  @override
  String get backToLearning => 'Back to Learning';

  @override
  String get microphonePermissionError => 'Failed to enable microphone';
}
