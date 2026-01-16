import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// Dart script to download Uthmanic Arabic Quran text
/// Run with: dart run scripts/download_quran_dart.dart

Future<Map<String, String>> downloadQuranFromAPI() async {
  print('Downloading Quran text from Quran.com API (Tanzil Uthmanic)...');
  
  final quranText = <String, String>{};
  
  try {
    // Download all 604 pages
    for (int pageNum = 1; pageNum <= 604; pageNum++) {
      try {
        final response = await http.get(
          Uri.parse('https://api.quran.com/api/v4/verses/by_page/$pageNum?language=ar&words=true'),
        ).timeout(const Duration(seconds: 10));
        
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final verses = data['verses'] as List?;
          
          if (verses != null && verses.isNotEmpty) {
            final pageVerses = <String>[];
            
            for (var verse in verses) {
              final words = verse['words'] as List?;
              if (words != null) {
                final verseText = words
                    .map((word) => word['text_uthmani'] as String? ?? '')
                    .where((text) => text.isNotEmpty)
                    .join(' ');
                pageVerses.add(verseText);
              }
            }
            
            quranText[pageNum.toString()] = pageVerses.join('\n');
            
            if (pageNum % 50 == 0) {
              print('Downloaded $pageNum/604 pages...');
            }
          }
        }
      } catch (e) {
        print('Error downloading page $pageNum: $e');
        continue;
      }
    }
    
    print('Downloaded ${quranText.length} pages');
    return quranText;
  } catch (e) {
    print('Error: $e');
    return {};
  }
}

Future<void> main() async {
  print('=' * 60);
  print('Quran Text Downloader - Uthmanic Script');
  print('Source: Tanzil Project (via Quran.com API)');
  print('=' * 60);
  
  final quranText = await downloadQuranFromAPI();
  
  if (quranText.isEmpty) {
    print('\n❌ Failed to download Quran text');
    print('Creating template file instead...');
    // Create template
    quranText['1'] = 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ\n\n'
        'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ\n'
        'الرَّحْمَٰنِ الرَّحِيمِ\n'
        'مَالِكِ يَوْمِ الدِّينِ\n'
        'إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ\n'
        'اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ\n'
        'صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ';
  }
  
  // Ensure directory exists
  final outputDir = Directory('assets/quran');
  if (!await outputDir.exists()) {
    await outputDir.create(recursive: true);
  }
  
  // Save to JSON
  final outputFile = File('assets/quran/quran_text.json');
  await outputFile.writeAsString(
    const JsonEncoder.withIndent('  ').convert(quranText),
    encoding: utf8,
  );
  
  print('\n✅ Quran text saved to: ${outputFile.path}');
  print('   Total pages: ${quranText.length}');
  print('   File size: ${(await outputFile.length()) / 1024} KB');
  
  if (quranText.length >= 600) {
    print('\n✅ Success! Quran text downloaded successfully.');
  } else {
    print('\n⚠️  Warning: Only ${quranText.length} pages downloaded. Expected 604 pages.');
  }
}
