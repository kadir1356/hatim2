import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import '../providers/hatim_provider.dart';
import '../providers/insights_provider.dart';
import '../providers/language_provider.dart';
// FIREBASE DISABLED
// import '../services/firebase_auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/progress_ring.dart';
import '../widgets/app_logo.dart';
import '../l10n/app_localizations.dart';
import 'reading_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isRTL = languageProvider.isRTL;

    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AppLogo(size: 28),
              const SizedBox(width: 12),
              Text('POCKET HATIM'),
            ],
          ),
          centerTitle: true,
        ),
        body: Consumer<HatimProvider>(
          builder: (context, hatimProvider, child) {
          if (hatimProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final hatim = hatimProvider.activeHatim;
          if (hatim == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Hatim bulunamadı'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      hatimProvider.createHatim('Personal Hatim');
                    },
                    child: const Text('Yeni Hatim Oluştur'),
                  ),
                ],
              ),
            );
          }

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Progress Ring with minimalist design
                    Center(
                      child: ProgressRing(
                        progress: hatim.progressPercentage / 100,
                        size: 180,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${hatim.progressPercentage.toStringAsFixed(1)}%',
                          style: AppTheme.uiTextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w300,
                            color: AppTheme.deepSageGreen,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${hatim.readPages} / ${hatim.totalPages}',
                          style: AppTheme.uiTextStyle(
                            fontSize: 14,
                            color: AppTheme.softCharcoal.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                    ),
                  ),
                  const SizedBox(height: 20),

                // Continue Reading Button (from Firestore or Local)
                if (!kIsWeb)
                  FutureBuilder<Map<String, dynamic>?>(
                    future: Provider.of<FirebaseAuthService?>(context, listen: false)?.getLastReadPage(),
                    builder: (context, snapshot) {
                      final lastReadData = snapshot.data;
                      final lastReadPage = lastReadData?['page'] ?? hatimProvider.lastReadPage?.pageNumber;
                      
                      if (lastReadPage != null && lastReadPage > 1) {
                        return ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ReadingScreen(
                                  initialPage: lastReadPage,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.auto_stories),
                          label: Text(
                            '${localizations.continueReading}: ${localizations.page} $lastReadPage',
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: AppTheme.deepSageGreen,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      } else {
                        return ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ReadingScreen(initialPage: 1),
                              ),
                            );
                          },
                          icon: const Icon(Icons.book),
                          label: Text(localizations.startReading),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: AppTheme.deepSageGreen,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      }
                    },
                  )
                else
                  // Web mode - use local storage only
                  if (hatimProvider.lastReadPage != null)
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReadingScreen(
                              initialPage: hatimProvider.lastReadPage!.pageNumber,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.auto_stories),
                      label: Text(
                        '${localizations.continueReading}: ${localizations.page} ${hatimProvider.lastReadPage!.pageNumber}',
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: AppTheme.deepSageGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    )
                  else
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ReadingScreen(initialPage: 1),
                          ),
                        );
                      },
                      icon: const Icon(Icons.book),
                      label: Text(localizations.startReading),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: AppTheme.deepSageGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      ),
                  const SizedBox(height: 16),

                  // Daily Streak with Glowing Lantern
                Consumer<InsightsProvider>(
                  builder: (context, insightsProvider, child) {
                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.warmCream,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppTheme.lightSageGreen.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Glowing Lantern Icon
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.deepSageGreen.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.local_fire_department,
                              color: AppTheme.deepSageGreen,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${insightsProvider.currentStreak}',
                                style: AppTheme.uiTextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w300,
                                  color: AppTheme.deepSageGreen,
                                ),
                              ),
                              Text(
                                '${localizations.dailyStreak}',
                                style: AppTheme.uiTextStyle(
                                  fontSize: 14,
                                  color: AppTheme.softCharcoal.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Quick Stats - Minimalist
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.warmCream,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppTheme.lightSageGreen.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localizations.statistics,
                        style: AppTheme.uiTextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _StatRow(
                        label: localizations.totalPages,
                        value: hatim.totalPages.toString(),
                        icon: Icons.menu_book,
                      ),
                      const SizedBox(height: 16),
                      _StatRow(
                        label: localizations.readPages,
                        value: hatim.readPages.toString(),
                        icon: Icons.check_circle,
                      ),
                      const SizedBox(height: 16),
                      _StatRow(
                        label: localizations.remainingPages,
                        value: (hatim.totalPages - hatim.readPages).toString(),
                        icon: Icons.bookmark_border,
                      ),
                    ],
                  ),
                ),
                ],
              ),
            ),
          ),
          );
          },
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppTheme.deepSageGreen.withOpacity(0.7),
          size: 20,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: AppTheme.uiTextStyle(
              fontSize: 15,
              color: AppTheme.softCharcoal.withOpacity(0.8),
            ),
          ),
        ),
        Text(
          value,
          style: AppTheme.uiTextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: AppTheme.deepSageGreen,
          ),
        ),
      ],
    );
  }
}
