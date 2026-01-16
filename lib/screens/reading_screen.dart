import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/hatim_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/language_provider.dart';
import '../services/quran_content_service.dart';
import '../services/firebase_auth_service.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import '../utils/quran_data.dart';

class ReadingScreen extends StatefulWidget {
  final int initialPage;
  final bool isCommunityJuz;
  final int? communityJuzNumber;
  final String? communityHatimId;

  const ReadingScreen({
    super.key,
    this.initialPage = 1,
    this.isCommunityJuz = false,
    this.communityJuzNumber,
    this.communityHatimId,
  });

  // Factory constructor for community Juz
  factory ReadingScreen.forCommunityJuz({
    required int juzNumber,
    required String communityHatimId,
  }) {
    // Get start page for this Juz
    final juz = QuranData.juzList.firstWhere(
      (j) => j.number == juzNumber,
      orElse: () => QuranData.juzList.isNotEmpty 
          ? QuranData.juzList.first 
          : QuranData.juzList[0], // Fallback to first Juz
    );
    return ReadingScreen(
      initialPage: juz.startPage,
      isCommunityJuz: true,
      communityJuzNumber: juzNumber,
      communityHatimId: communityHatimId,
    );
  }

  @override
  State<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends State<ReadingScreen> {
  late PageController _pageViewController;
  late int _currentPage;
  bool _isZenMode = false;
  Map<int, String> _quranPages = {}; // Cache for loaded pages
  bool _isLoading = true;
  FirebaseFirestore? get _firestore => kIsWeb ? null : FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
    // PageController starts at initialPage - 1 (0-indexed)
    _pageViewController = PageController(
      initialPage: widget.initialPage - 1,
      viewportFraction: 1.0,
    );
    _loadAllQuranPages();
  }

  @override
  void dispose() {
    _pageViewController.dispose();
    super.dispose();
  }

  Future<void> _loadAllQuranPages() async {
    try {
      print('📖 Loading all Quran pages...');
      final quranService = Provider.of<QuranContentService>(context, listen: false);
      
      // Ensure service is initialized
      await quranService.initialize();
      
      // Load all 604 pages
      final Map<int, String> loadedPages = {};
      for (int i = 1; i <= 604; i++) {
        final text = await quranService.loadPageText(i);
        if (text != null && text.isNotEmpty) {
          loadedPages[i] = text;
        } else {
          // Fallback placeholder
          loadedPages[i] = 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ\n\nالصفحة $i';
        }
      }
      
      if (mounted) {
        setState(() {
          _quranPages = loadedPages;
          _isLoading = false;
        });
        print('✅ Loaded ${_quranPages.length} Quran pages');
      }
    } catch (e) {
      print('❌ Error loading Quran pages: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _toggleZenMode() {
    setState(() {
      _isZenMode = !_isZenMode;
    });
    SystemChrome.setEnabledSystemUIMode(
      _isZenMode ? SystemUiMode.immersive : SystemUiMode.edgeToEdge,
    );
  }

  Future<void> _markPageAsRead() async {
    try {
      final hatimProvider = Provider.of<HatimProvider>(context, listen: false);
      await hatimProvider.markPageAsRead(_currentPage);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Page $_currentPage marked as read'),
            backgroundColor: AppTheme.deepSageGreen,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      print('Error marking page as read: $e');
    }
  }

  Future<void> _finishCommunityJuz() async {
    if (!widget.isCommunityJuz || widget.communityJuzNumber == null || widget.communityHatimId == null) {
      return;
    }

    if (_firestore == null) {
      // Web mode - show message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Community Hatim is only available on mobile'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Update status to 'completed_{uid}' in Firestore
      await _firestore!
          .collection('community_hatims')
          .doc(widget.communityHatimId)
          .update({
        'juz_status.${widget.communityJuzNumber}': 'completed_${user.uid}',
        'updated_at': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Juz ${widget.communityJuzNumber} completed! 🎉'),
            backgroundColor: AppTheme.deepSageGreen,
            duration: const Duration(seconds: 2),
          ),
        );
        
        // Navigate back
        Navigator.of(context).pop();
      }
    } catch (e) {
      print('Error finishing Juz: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  bool _isAtJuzEnd() {
    if (widget.communityJuzNumber == null) return false;
    
    final juz = QuranData.juzList.firstWhere(
      (j) => j.number == widget.communityJuzNumber,
      orElse: () => QuranData.juzList.isNotEmpty 
          ? QuranData.juzList.first 
          : QuranData.juzList[0], // Fallback to first Juz
    );
    
    return _currentPage >= juz.endPage;
  }

  // Get current Juz number based on page
  int _getCurrentJuz() {
    // Standard Madinah Mushaf Juz boundaries (simplified mapping)
    if (_currentPage <= 22) return 1;
    if (_currentPage <= 42) return 2;
    if (_currentPage <= 62) return 3;
    if (_currentPage <= 82) return 4;
    if (_currentPage <= 102) return 5;
    if (_currentPage <= 122) return 6;
    if (_currentPage <= 142) return 7;
    if (_currentPage <= 162) return 8;
    if (_currentPage <= 182) return 9;
    if (_currentPage <= 202) return 10;
    if (_currentPage <= 222) return 11;
    if (_currentPage <= 242) return 12;
    if (_currentPage <= 262) return 13;
    if (_currentPage <= 282) return 14;
    if (_currentPage <= 302) return 15;
    if (_currentPage <= 322) return 16;
    if (_currentPage <= 342) return 17;
    if (_currentPage <= 362) return 18;
    if (_currentPage <= 382) return 19;
    if (_currentPage <= 402) return 20;
    if (_currentPage <= 422) return 21;
    if (_currentPage <= 442) return 22;
    if (_currentPage <= 462) return 23;
    if (_currentPage <= 482) return 24;
    if (_currentPage <= 502) return 25;
    if (_currentPage <= 522) return 26;
    if (_currentPage <= 542) return 27;
    if (_currentPage <= 562) return 28;
    if (_currentPage <= 582) return 29;
    return 30;
  }

  // Show navigation dialog (Jump to Page or Juz)
  void _showNavigationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Navigate',
          style: AppTheme.uiTextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Jump to Page
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _showPageJumpDialog();
              },
              icon: const Icon(Icons.article_outlined),
              label: const Text('Go to Page (1-604)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.deepSageGreen,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 12),
            // Jump to Juz
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _showJuzJumpDialog();
              },
              icon: const Icon(Icons.menu_book),
              label: const Text('Go to Juz (1-30)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.mediumSageGreen,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  // Show Page Jump Dialog
  void _showPageJumpDialog() {
    final TextEditingController pageController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Jump to Page',
          style: AppTheme.uiTextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: pageController,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Enter page number (1-604)',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final pageNum = int.tryParse(pageController.text);
              if (pageNum != null && pageNum >= 1 && pageNum <= 604) {
                _pageViewController.jumpToPage(pageNum - 1); // 0-indexed
                setState(() {
                  _currentPage = pageNum;
                });
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.deepSageGreen,
              foregroundColor: Colors.white,
            ),
            child: const Text('Go'),
          ),
        ],
      ),
    );
  }

  // Show Juz Jump Dialog
  void _showJuzJumpDialog() {
    // Juz starting pages (Madinah Mushaf standard)
    final Map<int, int> juzStartPages = {
      1: 1, 2: 22, 3: 42, 4: 62, 5: 82,
      6: 102, 7: 122, 8: 142, 9: 162, 10: 182,
      11: 202, 12: 222, 13: 242, 14: 262, 15: 282,
      16: 302, 17: 322, 18: 342, 19: 362, 20: 382,
      21: 402, 22: 422, 23: 442, 24: 462, 25: 482,
      26: 502, 27: 522, 28: 542, 29: 562, 30: 582,
    };
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Select Juz',
          style: AppTheme.uiTextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: 30,
            itemBuilder: (context, index) {
              final juzNum = index + 1;
              final startPage = juzStartPages[juzNum]!;
              
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.deepSageGreen,
                  child: Text(
                    '$juzNum',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text('Juz $juzNum'),
                subtitle: Text('Starts at Page $startPage'),
                onTap: () {
                  _pageViewController.jumpToPage(startPage - 1); // 0-indexed
                  setState(() {
                    _currentPage = startPage;
                  });
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.warmCream,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                color: AppTheme.deepSageGreen,
              ),
              const SizedBox(height: 24),
              Text(
                '📖 Loading Quran...',
                style: AppTheme.uiTextStyle(
                  fontSize: 18,
                  color: AppTheme.softCharcoal,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_quranPages.isEmpty) {
      return Scaffold(
        backgroundColor: AppTheme.warmCream,
        appBar: AppBar(
          title: Text(localizations?.page ?? 'Page'),
          backgroundColor: AppTheme.warmCream,
        ),
        body: Center(
          child: Text(
            'No Quran text available. Please check your assets.',
            textAlign: TextAlign.center,
            style: AppTheme.uiTextStyle(fontSize: 16),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.warmCream,
      appBar: _isZenMode
          ? null
          : AppBar(
              title: Text(
                '${localizations?.page ?? 'Page'} $_currentPage / 604',
                style: AppTheme.uiTextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              backgroundColor: AppTheme.warmCream,
              elevation: 0,
              actions: [
                // Navigate to Page/Juz
                IconButton(
                  icon: const Icon(
                    Icons.search,
                    color: AppTheme.deepSageGreen,
                  ),
                  onPressed: _showNavigationDialog,
                  tooltip: 'Go to Page/Juz',
                ),
                // Mark as Completed (Community Juz only)
                if (widget.isCommunityJuz)
                  ElevatedButton.icon(
                    onPressed: _finishCommunityJuz,
                    icon: const Icon(Icons.check_circle, size: 20),
                    label: Text(localizations?.finishJuz ?? 'Finish Juz'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.deepSageGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      elevation: 0,
                    ),
                  ),
                // Zen Mode Toggle
                IconButton(
                  icon: Icon(
                    _isZenMode ? Icons.fullscreen_exit : Icons.fullscreen,
                    color: AppTheme.deepSageGreen,
                  ),
                  onPressed: _toggleZenMode,
                  tooltip: 'Zen Mode',
                ),
                // Mark as Read (Personal Hatim)
                if (!widget.isCommunityJuz)
                  IconButton(
                    icon: const Icon(
                      Icons.check_circle_outline,
                      color: AppTheme.deepSageGreen,
                    ),
                    onPressed: _markPageAsRead,
                    tooltip: 'Mark as Read',
                  ),
              ],
            ),
      body: Stack(
        children: [
          // Main PageView with RTL support (Right-to-Left swiping)
          Directionality(
            textDirection: TextDirection.rtl, // RTL for Arabic page navigation
            child: PageView.builder(
              controller: _pageViewController,
              reverse: true, // TRUE = Swiping right-to-left goes to next page (RTL)
              itemCount: 604,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index + 1; // Convert from 0-indexed to 1-indexed
                });
                
                // Update last read page in Firestore
                if (!kIsWeb) {
                  final authService = Provider.of<FirebaseAuthService?>(context, listen: false);
                  final juzNumber = _getCurrentJuz();
                  authService?.updateLastReadPage(_currentPage, juzNumber: juzNumber);
                }
              },
              itemBuilder: (context, index) {
                final pageNumber = index + 1;
                final pageText = _quranPages[pageNumber] ?? 'الصفحة $pageNumber';

                return _buildQuranPage(pageNumber, pageText);
              },
            ),
          ),

          // Floating Badge: Page + Juz Number (Right Side)
          if (!_isZenMode)
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.deepSageGreen.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'صفحة $_currentPage',
                      style: AppTheme.arabicTextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'جزء ${_getCurrentJuz()}',
                      style: AppTheme.arabicTextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Bottom Navigation (only in non-Zen mode)
          if (!_isZenMode)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: AppTheme.warmCream.withOpacity(0.95),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Previous Page
                    ElevatedButton.icon(
                      onPressed: _currentPage > 1
                          ? () {
                              _pageViewController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                          : null,
                      icon: const Icon(Icons.arrow_back, size: 20),
                      label: Text(
                        localizations?.previous ?? 'Previous',
                        style: AppTheme.uiTextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _currentPage > 1
                            ? AppTheme.deepSageGreen
                            : AppTheme.lightSageGreen.withOpacity(0.3),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                    ),

                    // Page Indicator
                    Text(
                      '$_currentPage / 604',
                      style: AppTheme.uiTextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.deepSageGreen,
                      ),
                    ),

                    // Next Page
                    ElevatedButton.icon(
                      onPressed: _currentPage < 604
                          ? () {
                              _pageViewController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                          : null,
                      icon: const Icon(Icons.arrow_forward, size: 20),
                      label: Text(
                        localizations?.next ?? 'Next',
                        style: AppTheme.uiTextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _currentPage < 604
                            ? AppTheme.deepSageGreen
                            : AppTheme.lightSageGreen.withOpacity(0.3),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Finish Juz Button (for community hatim)
          if (widget.isCommunityJuz && _isAtJuzEnd() && !kIsWeb && !_isZenMode)
            Positioned(
              top: 16,
              left: 0,
              right: 0,
              child: Center(
                child: ElevatedButton.icon(
                  onPressed: _finishCommunityJuz,
                  icon: const Icon(Icons.check_circle, color: Colors.white),
                  label: Text(
                    'Finish Juz ${widget.communityJuzNumber}',
                    style: AppTheme.uiTextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.deepSageGreen,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    elevation: 4,
                    shadowColor: AppTheme.deepSageGreen.withOpacity(0.4),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuranPage(int pageNumber, String pageText) {
    // Extract Bismillah from the text
    String? bismillah;
    String mainText = pageText;
    
    // Regex to match Bismillah (بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ)
    final bismillahPattern = RegExp(r'بِسْمِ\s*اللَّهِ\s*الرَّحْمَٰنِ\s*الرَّحِيمِ');
    final match = bismillahPattern.firstMatch(pageText);
    
    if (match != null) {
      bismillah = match.group(0);
      // Remove Bismillah from main text
      mainText = pageText.replaceFirst(bismillahPattern, '').trim();
    }
    
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: _isZenMode ? 40 : 16,
        bottom: _isZenMode ? 40 : 80, // Extra space for bottom navigation
      ),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Bismillah at the top (if exists) - RED color
              if (bismillah != null) ...[
                SelectableText(
                  bismillah,
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  style: AppTheme.arabicTextStyle(
                    fontSize: 28.0,
                    height: 1.8,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              // Arabic Quran Text (without Bismillah)
              SelectableText(
                mainText,
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl, // RTL for Arabic text
                style: AppTheme.arabicTextStyle(
                  fontSize: 24.0, // Slightly smaller for web
                  height: 2.0, // Generous line height for Harakat
                  color: AppTheme.softCharcoal,
                ),
              ),

              const SizedBox(height: 20),

              // Page Number (subtle)
              if (_isZenMode)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.deepSageGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$pageNumber',
                    style: AppTheme.uiTextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.deepSageGreen,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
