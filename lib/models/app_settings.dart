class AppSettings {
  double fontSize;
  bool notificationsEnabled;
  String? notificationTime;
  bool fullFocusMode;
  String userName;

  AppSettings({
    this.fontSize = 18.0,
    this.notificationsEnabled = true,
    this.notificationTime,
    this.fullFocusMode = false,
    this.userName = 'User',
  });

  AppSettings copyWith({
    double? fontSize,
    bool? notificationsEnabled,
    String? notificationTime,
    bool? fullFocusMode,
    String? userName,
  }) {
    return AppSettings(
      fontSize: fontSize ?? this.fontSize,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      notificationTime: notificationTime ?? this.notificationTime,
      fullFocusMode: fullFocusMode ?? this.fullFocusMode,
      userName: userName ?? this.userName,
    );
  }
}
