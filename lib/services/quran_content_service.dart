import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class QuranContentService {
  static QuranContentService? _instance;
  Map<int, String>? _quranTexts;

  QuranContentService._();

  factory QuranContentService() {
    _instance ??= QuranContentService._();
    return _instance!;
  }

  Future<void> initialize() async {
    if (_quranTexts != null) {
      print('QuranContentService already initialized with ${_quranTexts!.length} pages');
      return;
    }

    print('Initializing QuranContentService...');
    try {
      // Try to load from JSON file first
      await loadFromJson();
      
      // If loading from JSON failed or returned empty, use placeholders
      if (_quranTexts == null || _quranTexts!.isEmpty) {
        print('Warning: JSON loading returned empty, using placeholders');
        _quranTexts = {};
        for (int i = 1; i <= 604; i++) {
          _quranTexts![i] = _getPlaceholderText(i);
        }
      } else {
        print('Successfully initialized with ${_quranTexts!.length} pages from JSON');
      }
    } catch (e, stackTrace) {
      print('Error loading Quran content: $e');
      print('Stack trace: $stackTrace');
      // Fallback to placeholders
      print('Falling back to placeholder text');
      _quranTexts = {};
      for (int i = 1; i <= 604; i++) {
        _quranTexts![i] = _getPlaceholderText(i);
      }
    }
  }

  String _getPlaceholderText(int pageNumber) {
    // Placeholder - replace with actual Quran text
    // This will be shown if JSON file is not found
    return 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ\n\n'
        'الصفحة $pageNumber\n\n'
        'This is a placeholder. Please add the Quran text JSON file to assets/quran/quran_text.json\n\n'
        'Format: {"1": "Arabic text for page 1", "2": "Arabic text for page 2", ...}\n'
        'Or: {"pages": {"1": "text", "2": "text", ...}}';
  }
  
  // Method to get page text with proper Arabic formatting
  String? getFormattedPageText(int pageNumber) {
    final text = getPageText(pageNumber);
    if (text == null) return null;
    
    // Ensure proper Arabic text direction and formatting
    return text;
  }

  String? getPageText(int pageNumber) {
    if (_quranTexts == null) return null;
    return _quranTexts![pageNumber];
  }

  Future<String?> loadPageText(int pageNumber) async {
    if (_quranTexts == null) {
      print('Quran texts not initialized, initializing now...');
      await initialize();
    }
    if (_quranTexts == null) {
      print('Warning: _quranTexts is still null after initialization');
      return 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ\n\nالصفحة $pageNumber';
    }
    final text = getPageText(pageNumber);
    if (text == null) {
      print('Warning: Page $pageNumber not found in _quranTexts');
      return 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ\n\nالصفحة $pageNumber';
    }
    if (text.isEmpty) {
      print('Warning: Page $pageNumber text is empty');
      return 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ\n\nالصفحة $pageNumber';
    }
    print('Successfully loaded page $pageNumber (length: ${text.length})');
    return text;
  }

  // Method to load from JSON file (when you have the actual file)
  Future<void> loadFromJson() async {
    try {
      print('Attempting to load Quran JSON from assets...');
      print('Platform: ${kIsWeb ? "Web" : "Mobile"}');
      
      // Try loading with explicit asset path
      String jsonString;
      try {
        jsonString = await rootBundle.loadString('assets/quran/quran_text.json');
      } catch (e) {
        // On web, sometimes we need to try without the 'assets/' prefix
        if (kIsWeb) {
          print('First attempt failed, trying alternative path...');
          try {
            jsonString = await rootBundle.loadString('quran/quran_text.json');
          } catch (e2) {
            print('Alternative path also failed: $e2');
            rethrow;
          }
        } else {
          rethrow;
        }
      }
      
      print('JSON string loaded, length: ${jsonString.length}');
      
      if (jsonString.isEmpty) {
        print('Warning: JSON string is empty!');
        _quranTexts = null;
        return;
      }
      
      // Check if it's valid JSON
      if (!jsonString.trim().startsWith('{')) {
        print('Warning: JSON string does not start with {, might be corrupted');
        print('First 100 chars: ${jsonString.substring(0, jsonString.length > 100 ? 100 : jsonString.length)}');
      }
      
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      print('JSON decoded successfully, keys: ${jsonData.keys.length}');
      
      _quranTexts = {};
      
      // Handle different JSON structures
      if (jsonData.containsKey('pages')) {
        // Structure: {"pages": {"1": "text", "2": "text", ...}}
        final pages = jsonData['pages'] as Map<String, dynamic>;
        print('Found "pages" key with ${pages.length} entries');
        pages.forEach((key, value) {
          final pageNum = int.tryParse(key);
          if (pageNum != null) {
            final text = value.toString();
            if (text.isNotEmpty && text != 'null') {
              _quranTexts![pageNum] = text;
            }
          }
        });
      } else {
        // Structure: {"1": "text", "2": "text", ...}
        print('No "pages" key found, treating as direct page mapping');
        int loadedCount = 0;
        jsonData.forEach((key, value) {
          final pageNum = int.tryParse(key);
          if (pageNum != null) {
            final text = value.toString();
            if (text.isNotEmpty && text != 'null') {
              _quranTexts![pageNum] = text;
              loadedCount++;
            }
          }
        });
        print('Loaded $loadedCount pages from direct mapping');
      }
      
      print('Successfully loaded ${_quranTexts!.length} pages from JSON');
      if (_quranTexts!.isEmpty) {
        print('Warning: No pages were loaded! JSON might be empty or malformed.');
        print('Available keys in JSON: ${jsonData.keys.take(10).join(", ")}');
      } else {
        // Test first page
        final firstPage = _quranTexts![1];
        if (firstPage != null) {
          final preview = firstPage.length > 50 ? firstPage.substring(0, 50) : firstPage;
          print('Sample page 1 text (first 50 chars): $preview...');
        } else {
          print('Warning: Page 1 not found in loaded texts!');
        }
      }
    } catch (e, stackTrace) {
      print('Error loading Quran from JSON: $e');
      print('Stack trace: $stackTrace');
      print('Note: Make sure assets/quran/quran_text.json exists and is properly formatted.');
      // Will fallback to placeholder in initialize()
      _quranTexts = null;
      rethrow; // Re-throw to let initialize() handle it
    }
  }
}
