import '../models/surah.dart';
import '../models/juz.dart';
import '../models/page.dart';

class QuranData {
  // Total pages in Quran
  static const int totalPages = 604;

  // Juz information
  static final List<Juz> juzList = [
    Juz(number: 1, startPage: 1, endPage: 21, surahNumbers: [1, 2]),
    Juz(number: 2, startPage: 22, endPage: 41, surahNumbers: [2]),
    Juz(number: 3, startPage: 42, endPage: 61, surahNumbers: [2]),
    Juz(number: 4, startPage: 62, endPage: 81, surahNumbers: [2, 3]),
    Juz(number: 5, startPage: 82, endPage: 101, surahNumbers: [3, 4]),
    Juz(number: 6, startPage: 102, endPage: 121, surahNumbers: [4]),
    Juz(number: 7, startPage: 122, endPage: 141, surahNumbers: [4, 5]),
    Juz(number: 8, startPage: 142, endPage: 161, surahNumbers: [5, 6]),
    Juz(number: 9, startPage: 162, endPage: 181, surahNumbers: [6, 7]),
    Juz(number: 10, startPage: 182, endPage: 201, surahNumbers: [7, 8]),
    Juz(number: 11, startPage: 202, endPage: 221, surahNumbers: [8, 9]),
    Juz(number: 12, startPage: 222, endPage: 241, surahNumbers: [9, 10]),
    Juz(number: 13, startPage: 242, endPage: 261, surahNumbers: [10, 11]),
    Juz(number: 14, startPage: 262, endPage: 281, surahNumbers: [11, 12]),
    Juz(number: 15, startPage: 282, endPage: 301, surahNumbers: [12, 13, 14]),
    Juz(number: 16, startPage: 302, endPage: 321, surahNumbers: [15, 16]),
    Juz(number: 17, startPage: 322, endPage: 341, surahNumbers: [17, 18]),
    Juz(number: 18, startPage: 342, endPage: 361, surahNumbers: [18, 19]),
    Juz(number: 19, startPage: 362, endPage: 381, surahNumbers: [19, 20]),
    Juz(number: 20, startPage: 382, endPage: 401, surahNumbers: [20, 21]),
    Juz(number: 21, startPage: 402, endPage: 421, surahNumbers: [21, 22]),
    Juz(number: 22, startPage: 422, endPage: 441, surahNumbers: [22, 23]),
    Juz(number: 23, startPage: 442, endPage: 461, surahNumbers: [23, 24]),
    Juz(number: 24, startPage: 462, endPage: 481, surahNumbers: [24, 25]),
    Juz(number: 25, startPage: 482, endPage: 501, surahNumbers: [25, 26]),
    Juz(number: 26, startPage: 502, endPage: 521, surahNumbers: [26, 27]),
    Juz(number: 27, startPage: 522, endPage: 541, surahNumbers: [27, 28]),
    Juz(number: 28, startPage: 542, endPage: 561, surahNumbers: [28, 29]),
    Juz(number: 29, startPage: 562, endPage: 581, surahNumbers: [29, 30]),
    Juz(number: 30, startPage: 582, endPage: 604, surahNumbers: [30]),
  ];

  // Surah information (simplified - you can expand this)
  static final List<Surah> surahList = [
    Surah(number: 1, name: 'Al-Fatiha', arabicName: 'الفاتحة', ayahCount: 7, startPage: 1, endPage: 1),
    Surah(number: 2, name: 'Al-Baqarah', arabicName: 'البقرة', ayahCount: 286, startPage: 2, endPage: 49),
    Surah(number: 3, name: 'Ali Imran', arabicName: 'آل عمران', ayahCount: 200, startPage: 50, endPage: 76),
    // Add more surahs as needed - this is a simplified version
    // For a full implementation, you'd include all 114 surahs
  ];

  // Get juz for a page
  static Juz? getJuzForPage(int pageNumber) {
    return juzList.firstWhere(
      (juz) => pageNumber >= juz.startPage && pageNumber <= juz.endPage,
      orElse: () => juzList.first,
    );
  }

  // Get surahs for a page
  static List<int> getSurahsForPage(int pageNumber) {
    final juz = getJuzForPage(pageNumber);
    if (juz == null) return [];
    
    // Simplified logic - in a real app, you'd have precise page-to-surah mapping
    return juz.surahNumbers;
  }

  // Create all pages for a Hatim
  static List<Page> createAllPages() {
    final List<Page> pages = [];
    for (int i = 1; i <= totalPages; i++) {
      pages.add(Page(
        pageNumber: i,
        juzNumber: getJuzForPage(i)?.number ?? 1,
        surahNumbers: getSurahsForPage(i),
      ));
    }
    return pages;
  }
}
