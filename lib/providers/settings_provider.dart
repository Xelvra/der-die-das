import 'dart:io';
import 'package:der_die_das/models/card_style.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:vibration/vibration.dart';
import 'shared_prefs_provider.dart';

class SettingsState {
  final bool isHapticsEnabled;
  final bool isPowerSavingEnabled;
  final bool isNotificationsEnabled;
  final bool isAutoSpeechEnabled;
  final bool isSpeechRecognitionEnabled;
  final CardStyle cardStyle;
  final List<String> helpTabOrder;

  const SettingsState({
    this.isHapticsEnabled = false,
    this.isPowerSavingEnabled = false,
    this.isNotificationsEnabled = false,
    this.isAutoSpeechEnabled = false,
    this.isSpeechRecognitionEnabled = false,
    this.cardStyle = CardStyle.modern,
    this.helpTabOrder = const ['swiping', 'tips', 'keyboard'],
  });

  SettingsState copyWith({
    bool? isHapticsEnabled,
    bool? isPowerSavingEnabled,
    bool? isNotificationsEnabled,
    bool? isAutoSpeechEnabled,
    bool? isSpeechRecognitionEnabled,
    CardStyle? cardStyle,
    List<String>? helpTabOrder,
  }) {
    return SettingsState(
      isHapticsEnabled: isHapticsEnabled ?? this.isHapticsEnabled,
      isPowerSavingEnabled: isPowerSavingEnabled ?? this.isPowerSavingEnabled,
      isNotificationsEnabled:
          isNotificationsEnabled ?? this.isNotificationsEnabled,
      isAutoSpeechEnabled: isAutoSpeechEnabled ?? this.isAutoSpeechEnabled,
      isSpeechRecognitionEnabled:
          isSpeechRecognitionEnabled ?? this.isSpeechRecognitionEnabled,
      cardStyle: cardStyle ?? this.cardStyle,
      helpTabOrder: helpTabOrder ?? this.helpTabOrder,
    );
  }
}

class SettingsNotifier extends Notifier<SettingsState> {
  static const _kHapticsKey = 'is_haptics_enabled';
  static const _kPowerSavingKey = 'power_saving_enabled';
  static const _kNotificationsKey = 'daily_reminder_enabled';
  static const _kAutoSpeechKey = 'auto_speech_enabled';
  static const _kSpeechRecognitionKey = 'speech_recognition_enabled';
  static const _kCardStyleKey = 'card_style';
  static const _kHelpTabOrderKey = 'help_tab_order';

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  bool _isNotificationsInitialized = false;

  @override
  SettingsState build() {
    final prefs = ref.watch(sharedPreferencesProvider);

    final haptics = prefs.getBool(_kHapticsKey) ?? false;
    final powerSaving = prefs.getBool(_kPowerSavingKey) ?? false;
    final notifications = prefs.getBool(_kNotificationsKey) ?? false;
    final autoSpeech = prefs.getBool(_kAutoSpeechKey) ?? false;
    final speechRecognition = prefs.getBool(_kSpeechRecognitionKey) ?? false;
    final cardStyleIndex =
        prefs.getInt(_kCardStyleKey) ?? CardStyle.modern.index;
    final helpTabOrder = prefs.getStringList(_kHelpTabOrderKey) ??
        const ['swiping', 'tips', 'keyboard'];

    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      // Defer initialization to avoid side effects in build
      Future.microtask(() => _initNotifications(notifications));
    }

    return SettingsState(
      isHapticsEnabled: haptics,
      isPowerSavingEnabled: powerSaving,
      isNotificationsEnabled: notifications,
      isAutoSpeechEnabled: autoSpeech,
      isSpeechRecognitionEnabled: speechRecognition,
      cardStyle: CardStyle
          .values[cardStyleIndex.clamp(0, CardStyle.values.length - 1)],
      helpTabOrder: helpTabOrder,
    );
  }

  // --- Card Style ---
  void setCardStyle(CardStyle style) {
    state = state.copyWith(cardStyle: style);
    ref.read(sharedPreferencesProvider).setInt(_kCardStyleKey, style.index);
  }

  // --- Speech Recognition ---
  Future<bool> toggleSpeechRecognition(bool value) async {
    if (value) {
      // Request permission
      final status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        state = state.copyWith(isSpeechRecognitionEnabled: false);
        ref
            .read(sharedPreferencesProvider)
            .setBool(_kSpeechRecognitionKey, false);
        return false;
      }
    }

    state = state.copyWith(isSpeechRecognitionEnabled: value);
    ref.read(sharedPreferencesProvider).setBool(_kSpeechRecognitionKey, value);
    return true;
  }

  // --- Help Tab Order ---
  void updateHelpTabOrder(List<String> newOrder) {
    state = state.copyWith(helpTabOrder: newOrder);
    ref
        .read(sharedPreferencesProvider)
        .setStringList(_kHelpTabOrderKey, newOrder);
  }

  // --- Haptics ---
  Future<void> toggleHaptics(bool value) async {
    state = state.copyWith(isHapticsEnabled: value);
    ref.read(sharedPreferencesProvider).setBool(_kHapticsKey, value);

    // Trigger feedback on enable to confirm it works
    if (value) {
      if (await Vibration.hasVibrator()) {
        Vibration.vibrate(duration: 50);
      }
    }
  }

  // --- Power Saving ---
  void togglePowerSaving(bool value) {
    state = state.copyWith(isPowerSavingEnabled: value);
    ref.read(sharedPreferencesProvider).setBool(_kPowerSavingKey, value);
  }

  // --- Auto Speech ---
  void toggleAutoSpeech(bool value) {
    state = state.copyWith(isAutoSpeechEnabled: value);
    ref.read(sharedPreferencesProvider).setBool(_kAutoSpeechKey, value);
  }

  // --- Notifications ---
  Future<void> _initNotifications(bool enabled) async {
    if (_isNotificationsInitialized) return;
    try {
      tz.initializeTimeZones();
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      await _notifications.initialize(const InitializationSettings(
          android: androidSettings, iOS: iosSettings));
      _isNotificationsInitialized = true;
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to initialize notifications: $e');
    }
  }

  Future<void> toggleNotifications(bool enabled,
      {String? title, String? body}) async {
    if (!_isNotificationsInitialized) await _initNotifications(enabled);

    final prefs = ref.read(sharedPreferencesProvider);

    if (enabled) {
      bool granted = await _requestPermissions();
      if (!granted) {
        state = state.copyWith(isNotificationsEnabled: false);
        await prefs.setBool(_kNotificationsKey, false);
        return;
      }
      await _scheduleDailyNotification(title: title, body: body);
    } else {
      await _notifications.cancelAll();
    }

    state = state.copyWith(isNotificationsEnabled: enabled);
    await prefs.setBool(_kNotificationsKey, enabled);
  }

  Future<bool> _requestPermissions() async {
    if (kIsWeb) return false;
    if (Platform.isIOS) {
      return await _notifications
              .resolvePlatformSpecificImplementation<
                  IOSFlutterLocalNotificationsPlugin>()
              ?.requestPermissions(alert: true, badge: true, sound: true) ??
          false;
    } else if (Platform.isAndroid) {
      return await _notifications
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              ?.requestNotificationsPermission() ??
          false;
    }
    return true;
  }

  Future<void> _scheduleDailyNotification({String? title, String? body}) async {
    if (!_isNotificationsInitialized) return;
    await _notifications.cancelAll();

    const details = NotificationDetails(
      android: AndroidNotificationDetails('daily_reminder', 'Daily Reminder',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority),
      iOS: DarwinNotificationDetails(),
    );

    try {
      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate =
          tz.TZDateTime(tz.local, now.year, now.month, now.day, 18, 0);
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      await _notifications.zonedSchedule(0, title ?? 'Time for German!',
          body ?? "Let's practice some words today.", scheduledDate, details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time);
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to schedule notification: $e');
    }
  }
}

final settingsProvider =
    NotifierProvider<SettingsNotifier, SettingsState>(SettingsNotifier.new);
