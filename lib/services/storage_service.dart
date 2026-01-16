import 'package:hive_flutter/hive_flutter.dart';
import '../models/hatim.dart';
import '../models/page.dart';
import '../models/reading_session.dart';
import '../models/app_settings.dart';
import '../utils/quran_data.dart';

class StorageService {
  static const String hatimBoxName = 'hatims';
  static const String sessionsBoxName = 'reading_sessions';
  static const String settingsBoxName = 'settings';

  late Box _hatimBox;
  late Box _sessionsBox;
  late Box _settingsBox;

  Future<void> init() async {
    // Note: Hive.initFlutter() should be called in main.dart before this
    
    try {
      print('🔧 Opening Hive boxes...');
      // Open boxes as generic Box (not typed) for web compatibility
      _hatimBox = await Hive.openBox(hatimBoxName);
      _sessionsBox = await Hive.openBox(sessionsBoxName);
      _settingsBox = await Hive.openBox(settingsBoxName);
      print('✅ Hive boxes opened successfully');

      // Initialize default settings if not exists
      if (_settingsBox.isEmpty) {
        print('📝 Creating default settings...');
        await _settingsBox.put('default', _settingsToJson(AppSettings()));
      }

      // Create default hatim if none exists
      if (_hatimBox.isEmpty) {
        print('📚 Creating default hatim...');
        await createDefaultHatim();
      }
      
      print('✅ Storage service initialized with ${_hatimBox.length} hatims');
    } catch (e, stackTrace) {
      print('❌ Error opening Hive boxes: $e');
      print('Stack trace: $stackTrace');
      // Try to continue with empty boxes - will fail gracefully later
      try {
        _hatimBox = await Hive.openBox(hatimBoxName);
        _sessionsBox = await Hive.openBox(sessionsBoxName);
        _settingsBox = await Hive.openBox(settingsBoxName);
        print('⚠️ Recovered with empty boxes');
      } catch (e2) {
        print('❌ Failed to recover boxes: $e2');
        // App will work with limited functionality (no persistence)
        rethrow; // Let main.dart handle this
      }
    }
  }

  Future<void> createDefaultHatim() async {
    final pages = QuranData.createAllPages();
    final defaultHatim = Hatim(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: 'Personal Hatim',
      createdAt: DateTime.now(),
      pages: pages,
    );
    await _hatimBox.put(defaultHatim.id, _hatimToJson(defaultHatim));
  }

  // JSON conversion helpers
  Map<String, dynamic> _hatimToJson(Hatim hatim) {
    return {
      'id': hatim.id,
      'name': hatim.name,
      'createdAt': hatim.createdAt.toIso8601String(),
      'pages': hatim.pages.map((p) => _pageToJson(p)).toList(),
      'isActive': hatim.isActive,
    };
  }

  Hatim _hatimFromJson(Map<String, dynamic> json) {
    return Hatim(
      id: json['id'],
      name: json['name'],
      createdAt: DateTime.parse(json['createdAt']),
      pages: (json['pages'] as List).map((p) => _pageFromJson(p)).toList(),
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> _pageToJson(Page page) {
    return {
      'pageNumber': page.pageNumber,
      'juzNumber': page.juzNumber,
      'surahNumbers': page.surahNumbers,
      'isRead': page.isRead,
      'readDate': page.readDate?.toIso8601String(),
    };
  }

  Page _pageFromJson(Map<String, dynamic> json) {
    return Page(
      pageNumber: json['pageNumber'],
      juzNumber: json['juzNumber'],
      surahNumbers: List<int>.from(json['surahNumbers']),
      isRead: json['isRead'] ?? false,
      readDate: json['readDate'] != null ? DateTime.parse(json['readDate']) : null,
    );
  }

  Map<String, dynamic> _sessionToJson(ReadingSession session) {
    return {
      'date': session.date.toIso8601String(),
      'pagesRead': session.pagesRead,
      'hatimId': session.hatimId,
    };
  }

  ReadingSession _sessionFromJson(Map<String, dynamic> json) {
    return ReadingSession(
      date: DateTime.parse(json['date']),
      pagesRead: json['pagesRead'],
      hatimId: json['hatimId'],
    );
  }

  Map<String, dynamic> _settingsToJson(AppSettings settings) {
    return {
      'fontSize': settings.fontSize,
      'notificationsEnabled': settings.notificationsEnabled,
      'notificationTime': settings.notificationTime,
      'fullFocusMode': settings.fullFocusMode,
    };
  }

  AppSettings _settingsFromJson(Map<String, dynamic> json) {
    return AppSettings(
      fontSize: json['fontSize']?.toDouble() ?? 18.0,
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      notificationTime: json['notificationTime'],
      fullFocusMode: json['fullFocusMode'] ?? false,
    );
  }

  // Helper to safely convert dynamic to Map<String, dynamic>
  Map<String, dynamic> _toMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    } else if (value is Map) {
      return Map<String, dynamic>.from(value);
    } else {
      return {};
    }
  }

  // Hatim operations
  List<Hatim> getAllHatims() {
    try {
      return _hatimBox.values
          .map((value) => _hatimFromJson(_toMap(value)))
          .toList();
    } catch (e) {
      print('Error loading hatims: $e');
      return [];
    }
  }

  Hatim? getHatim(String id) {
    try {
      final json = _hatimBox.get(id);
      if (json == null) return null;
      return _hatimFromJson(_toMap(json));
    } catch (e) {
      print('Error getting hatim: $e');
      return null;
    }
  }

  Hatim? getActiveHatim() {
    try {
      final hatims = getAllHatims();
      return hatims.firstWhere(
        (hatim) => hatim.isActive,
        orElse: () => hatims.isNotEmpty ? hatims.first : Hatim(
          id: '',
          name: '',
          createdAt: DateTime.now(),
          pages: [],
        ),
      );
    } catch (e) {
      print('Error getting active hatim: $e');
      return null;
    }
  }

  Future<void> saveHatim(Hatim hatim) async {
    await _hatimBox.put(hatim.id, _hatimToJson(hatim));
  }

  Future<void> deleteHatim(String id) async {
    await _hatimBox.delete(id);
  }

  Future<void> setActiveHatim(String id) async {
    try {
      // Deactivate all hatims
      for (var key in _hatimBox.keys) {
        final hatim = _hatimFromJson(_toMap(_hatimBox.get(key)));
        if (hatim.isActive) {
          await _hatimBox.put(key, _hatimToJson(hatim.copyWith(isActive: false)));
        }
      }
      // Activate selected hatim
      final hatim = getHatim(id);
      if (hatim != null) {
        await _hatimBox.put(id, _hatimToJson(hatim.copyWith(isActive: true)));
      }
    } catch (e) {
      print('Error setting active hatim: $e');
    }
  }

  // Reading session operations
  Future<void> addReadingSession(ReadingSession session) async {
    await _sessionsBox.add(_sessionToJson(session));
  }

  List<ReadingSession> getReadingSessions() {
    try {
      return _sessionsBox.values
          .map((value) => _sessionFromJson(_toMap(value)))
          .toList();
    } catch (e) {
      print('Error loading reading sessions: $e');
      return [];
    }
  }

  List<ReadingSession> getSessionsForDateRange(DateTime start, DateTime end) {
    return getReadingSessions().where((session) {
      return session.date.isAfter(start.subtract(const Duration(days: 1))) &&
          session.date.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  // Settings operations
  AppSettings getSettings() {
    try {
      final json = _settingsBox.get('default');
      if (json == null) return AppSettings();
      return _settingsFromJson(_toMap(json));
    } catch (e) {
      print('Error loading settings: $e');
      return AppSettings();
    }
  }

  Future<void> saveSettings(AppSettings settings) async {
    await _settingsBox.put('default', _settingsToJson(settings));
  }

  // Streak calculation
  int getCurrentStreak() {
    final sessions = getReadingSessions();
    if (sessions.isEmpty) return 0;

    sessions.sort((a, b) => b.date.compareTo(a.date));
    
    int streak = 0;
    DateTime checkDate = DateTime.now();
    final today = DateTime(checkDate.year, checkDate.month, checkDate.day);

    for (var session in sessions) {
      final sessionDate = DateTime(session.date.year, session.date.month, session.date.day);
      final daysDiff = today.difference(sessionDate).inDays;

      if (daysDiff == streak) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else if (daysDiff > streak) {
        break;
      }
    }

    return streak;
  }

  // Heat map data (last 30 days)
  Map<DateTime, int> getHeatMapData() {
    final Map<DateTime, int> heatMap = {};
    final now = DateTime.now();
    
    for (int i = 0; i < 30; i++) {
      final date = now.subtract(Duration(days: i));
      final dateOnly = DateTime(date.year, date.month, date.day);
      heatMap[dateOnly] = 0;
    }

    for (var session in getReadingSessions()) {
      final sessionDate = DateTime(session.date.year, session.date.month, session.date.day);
      if (heatMap.containsKey(sessionDate)) {
        heatMap[sessionDate] = (heatMap[sessionDate] ?? 0) + session.pagesRead;
      }
    }

    return heatMap;
  }
}
