class AppSettings {
  double fontSize;
  bool notificationsEnabled;
  String? notificationTime;
  bool fullFocusMode;

  AppSettings({
    this.fontSize = 18.0,
    this.notificationsEnabled = true,
    this.notificationTime,
    this.fullFocusMode = false,
  });

  AppSettings copyWith({
    double? fontSize,
    bool? notificationsEnabled,
    String? notificationTime,
    bool? fullFocusMode,
  }) {
    return AppSettings(
      fontSize: fontSize ?? this.fontSize,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      notificationTime: notificationTime ?? this.notificationTime,
      fullFocusMode: fullFocusMode ?? this.fullFocusMode,
    );
  }
}
