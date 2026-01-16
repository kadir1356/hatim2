import 'package:flutter/foundation.dart';
import '../services/storage_service.dart';
import '../models/reading_session.dart';

class InsightsProvider with ChangeNotifier {
  final StorageService _storageService;

  InsightsProvider(this._storageService);

  int get currentStreak => _storageService.getCurrentStreak();

  Map<DateTime, int> get heatMapData => _storageService.getHeatMapData();

  List<ReadingSession> getRecentSessions({int days = 7}) {
    final end = DateTime.now();
    final start = end.subtract(Duration(days: days));
    return _storageService.getSessionsForDateRange(start, end);
  }

  int getTotalPagesRead() {
    final sessions = _storageService.getReadingSessions();
    return sessions.fold(0, (sum, session) => sum + session.pagesRead);
  }

  int getPagesReadThisMonth() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final sessions = _storageService.getSessionsForDateRange(startOfMonth, now);
    return sessions.fold(0, (sum, session) => sum + session.pagesRead);
  }
}
