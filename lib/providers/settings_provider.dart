import 'package:flutter/foundation.dart';
import '../models/app_settings.dart';
import '../services/storage_service.dart';

class SettingsProvider with ChangeNotifier {
  final StorageService _storageService;
  AppSettings _settings;

  SettingsProvider(this._storageService) : _settings = _storageService.getSettings();

  AppSettings get settings => _settings;

  double get fontSize => _settings.fontSize;
  bool get notificationsEnabled => _settings.notificationsEnabled;
  String? get notificationTime => _settings.notificationTime;
  bool get fullFocusMode => _settings.fullFocusMode;
  String get userName => _settings.userName;

  Future<void> updateFontSize(double size) async {
    _settings = _settings.copyWith(fontSize: size);
    await _storageService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> updateNotificationsEnabled(bool enabled) async {
    _settings = _settings.copyWith(notificationsEnabled: enabled);
    await _storageService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> updateNotificationTime(String? time) async {
    _settings = _settings.copyWith(notificationTime: time);
    await _storageService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> updateFullFocusMode(bool enabled) async {
    _settings = _settings.copyWith(fullFocusMode: enabled);
    await _storageService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> updateUserName(String name) async {
    _settings = _settings.copyWith(userName: name);
    await _storageService.saveSettings(_settings);
    notifyListeners();
  }
}
