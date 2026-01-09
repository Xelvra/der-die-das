// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get menu => 'Меню';

  @override
  String get colorTheme => 'Настройки';

  @override
  String get help => 'Помощь';

  @override
  String get helpSwiping => 'Свайпы';

  @override
  String get helpSwipingContent =>
      'Сдвигай карточки к правильному артиклю. Нажми и удерживай карточку, чтобы увидеть подсказку';

  @override
  String get helpTips => 'Советы';

  @override
  String get helpTipsContent =>
      'Общие суффиксы и категории, которые помогают определить правильный артикль';

  @override
  String get helpKeyboard => 'Клавиатура';

  @override
  String get helpKeyboardContent =>
      'Управляй игрой на ПК с помощью горячих клавиш';

  @override
  String get helpArrows => 'Стрелки';

  @override
  String get helpSystem => 'Система';

  @override
  String get helpReveal => 'Показать';

  @override
  String get swipeLeft => 'Свайп влево для «die»';

  @override
  String get swipeUp => 'Свайп вверх для «das»';

  @override
  String get swipeRight => 'Свайп вправо для «der»';

  @override
  String get longPressHint => 'Удерживайте для помощи';

  @override
  String get level => 'Изучение';

  @override
  String get noWordsFound => 'Слова не найдены';

  @override
  String get openMenuTooltip => 'Открыть меню';

  @override
  String get themeLight => 'Светлая';

  @override
  String get themeDark => 'Темная';

  @override
  String get themeSepia => 'Сепия';

  @override
  String get themeMidnight => 'Полночь';

  @override
  String get themeNordic => 'Нордик';

  @override
  String get themeForest => 'Лес';

  @override
  String get themeSakura => 'Сакура';

  @override
  String get themeNeon => 'Неон';

  @override
  String get training => 'Тренировка';

  @override
  String get reviewLearned => 'Повторение';

  @override
  String get survival => 'Гонка';

  @override
  String get challenge => 'Перетягивание';

  @override
  String get weakPoints => 'Слабые места';

  @override
  String levelTitle(Object level) {
    return 'Уровень $level';
  }

  @override
  String get tryAgain => 'Повторить';

  @override
  String get gameOver => 'Игра окончена';

  @override
  String get endGame => 'Завершить';

  @override
  String survivalScore(Object score) {
    return 'Счет: $score';
  }

  @override
  String get statsTitle => 'Статистика';

  @override
  String get currentStreak => 'Текущая серия';

  @override
  String get streakDays => 'дн.';

  @override
  String get globalProgress => 'Общий прогресс';

  @override
  String learnedStats(Object learned, Object total) {
    return 'Изучено $learned из $total слов';
  }

  @override
  String get hallOfFame => 'Зал славы';

  @override
  String get noScores => 'Результатов нет';

  @override
  String get points => 'очков';

  @override
  String get donateTitle => 'Угости меня кофе';

  @override
  String get donateSubtitle => 'Поддержать проект';

  @override
  String get menuStats => 'Статистика';

  @override
  String get about => 'О приложении';

  @override
  String get refreshStats => 'Обновить';

  @override
  String get haptics => 'Вибрация';

  @override
  String get dailyReminder => 'Напоминание';

  @override
  String get dailyReminderDesc => 'Уведомления о практике';

  @override
  String get powerSaving => 'Экономия энергии';

  @override
  String get powerSavingDesc => 'Затемнять экран';

  @override
  String get autoSpeech => 'Автопроизношение';

  @override
  String get cardStyle => 'Стиль карточек';

  @override
  String get cardStyleModern => 'Модерн';

  @override
  String get cardStyleClassic => 'Классика';

  @override
  String get cardStyleGothic => 'Швабах';

  @override
  String get fontSettingsTitle => 'Шрифт';

  @override
  String get handsFree => 'Голосовое управление';

  @override
  String get listenTooltip => 'Прослушать';

  @override
  String get dailyReminderTitle => 'Время немецкого!';

  @override
  String get dailyReminderBody => 'Давай попрактикуем слова сегодня.';

  @override
  String get yes => 'Да';

  @override
  String get no => 'Нет';

  @override
  String get back => 'Назад';

  @override
  String get tipUng => '-ung, -heit, -keit, -schaft';

  @override
  String get tipChen => '-chen, -lein, -um';

  @override
  String get tipIg => '-ig, -ling, -ismus';

  @override
  String get tipTime => 'Дни, месяцы, сезоны';

  @override
  String get tipAuto => 'Марки машин, поезда';

  @override
  String get tipForeign => 'Слова на -ma';

  @override
  String get license => 'Лицензия';

  @override
  String get keyLeft => 'Der';

  @override
  String get keyDown => 'Die';

  @override
  String get keyRight => 'Das';

  @override
  String get keyMenu => 'Меню';

  @override
  String get autoplay => 'Авто-режим';

  @override
  String get continues => 'Продолжить';

  @override
  String get levelComplete => 'Отличная работа!';

  @override
  String get keepItUp => 'Ты завершил еще одну часть тренировки.\nТак держать!';

  @override
  String get backToLearning => 'К изучению';

  @override
  String get microphonePermissionError => 'Не удалось включить микрофон';
}
