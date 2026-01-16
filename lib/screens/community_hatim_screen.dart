import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';

/// COMMUNITY HATIM SCREEN (Firebase Disabled)
/// This feature requires Firebase Firestore for real-time collaboration.
/// Currently disabled for stable Android builds.

class CommunityHatimScreen extends StatelessWidget {
  const CommunityHatimScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppTheme.warmCream,
      appBar: AppBar(
        title: Text(localizations?.communityHatim ?? 'Community Hatim'),
        backgroundColor: AppTheme.warmCream,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.cloud_off,
                size: 80,
                color: AppTheme.softCharcoal.withOpacity(0.5),
              ),
              const SizedBox(height: 24),
              Text(
                'Community Hatim Unavailable',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppTheme.deepSageGreen,
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Firebase has been temporarily disabled for stable Android builds. '
                'This feature requires cloud synchronization and will be re-enabled in a future update.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.softCharcoal.withOpacity(0.7),
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Go Back'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.deepSageGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
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
