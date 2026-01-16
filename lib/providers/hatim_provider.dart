import 'package:flutter/foundation.dart';
import '../models/hatim.dart';
import '../models/page.dart';
import '../models/reading_session.dart';
import '../services/storage_service.dart';
import '../utils/quran_data.dart';

class HatimProvider with ChangeNotifier {
  final StorageService _storageService;
  Hatim? _activeHatim;
  List<Hatim> _hatims = [];
  bool _isLoading = true;

  HatimProvider(this._storageService) {
    _initialize();
  }

  Hatim? get activeHatim => _activeHatim;
  List<Hatim> get hatims => _hatims;
  bool get isLoading => _isLoading;

  Future<void> _initialize() async {
    _isLoading = true;
    notifyListeners();
    // Wait a bit to ensure storage is ready
    await Future.delayed(const Duration(milliseconds: 100));
    _loadHatims();
    _isLoading = false;
    notifyListeners();
  }

  void _loadHatims() {
    try {
      _hatims = _storageService.getAllHatims();
      _activeHatim = _storageService.getActiveHatim();
      
      // If no active hatim, create one
      if (_activeHatim == null && _hatims.isEmpty) {
        _storageService.createDefaultHatim();
        _hatims = _storageService.getAllHatims();
        _activeHatim = _storageService.getActiveHatim();
      }
    } catch (e) {
      print('Error loading hatims: $e');
    }
    notifyListeners();
  }

  Future<void> markPageAsRead(int pageNumber, {bool isRead = true}) async {
    if (_activeHatim == null) return;

    final pageIndex = _activeHatim!.pages.indexWhere((p) => p.pageNumber == pageNumber);
    if (pageIndex == -1) return;

    final updatedPage = _activeHatim!.pages[pageIndex].copyWith(
      isRead: isRead,
      readDate: isRead ? DateTime.now() : null,
    );

    final updatedPages = List<Page>.from(_activeHatim!.pages);
    updatedPages[pageIndex] = updatedPage;

    final updatedHatim = _activeHatim!.copyWith(pages: updatedPages);
    await _storageService.saveHatim(updatedHatim);
    
    // Record reading session
    if (isRead) {
      await _storageService.addReadingSession(
        ReadingSession(
          date: DateTime.now(),
          pagesRead: 1,
          hatimId: updatedHatim.id,
        ),
      );
    }

    _loadHatims();
  }

  Future<void> createHatim(String name) async {
    final pages = QuranData.createAllPages();
    final newHatim = Hatim(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      createdAt: DateTime.now(),
      pages: pages,
      isActive: false,
    );
    await _storageService.saveHatim(newHatim);
    _loadHatims();
  }

  Future<void> setActiveHatim(String id) async {
    await _storageService.setActiveHatim(id);
    _loadHatims();
  }

  Future<void> deleteHatim(String id) async {
    await _storageService.deleteHatim(id);
    _loadHatims();
  }

  double get progressPercentage {
    return _activeHatim?.progressPercentage ?? 0.0;
  }

  Page? get lastReadPage {
    return _activeHatim?.lastReadPage;
  }
}
