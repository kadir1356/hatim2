import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
// FIREBASE DISABLED
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import '../services/firebase_auth_service.dart';
import '../services/donation_service.dart';
import '../providers/hatim_provider.dart';
import '../providers/language_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import '../widgets/progress_ring.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch LanguageProvider to rebuild when language changes
    context.watch<LanguageProvider>();
    final localizations = AppLocalizations.of(context);
    
    // Web'de Firebase çalışmıyor - offline profile göster
    if (kIsWeb) {
      return Scaffold(
        backgroundColor: AppTheme.warmCream,
        appBar: AppBar(
          title: Text(localizations?.profile ?? 'Profile'),
          backgroundColor: AppTheme.warmCream,
        ),
        body: Consumer2<HatimProvider, SettingsProvider>(
          builder: (context, hatimProvider, settingsProvider, child) {
            final hatim = hatimProvider.activeHatim;
            final userName = settingsProvider.userName;
            
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 50,
                    backgroundColor: AppTheme.deepSageGreen,
                    child: Text(
                      userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                      style: const TextStyle(
                        fontSize: 48,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        userName,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: AppTheme.deepSageGreen,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        color: AppTheme.deepSageGreen,
                        onPressed: () => _showEditNameDialog(context, settingsProvider),
                        tooltip: 'Edit name',
                      ),
                      ],
                    ),
                    const SizedBox(height: 6),
                  Text(
                    'Sign in on mobile for full features',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.softCharcoal.withOpacity(0.7),
                        ),
                  ),
                    if (hatim != null) ...[
                      const SizedBox(height: 20),
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: AppTheme.softCharcoal.withOpacity(0.1),
                          width: 0.5,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Text(
                              'Reading Progress',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: AppTheme.deepSageGreen,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            ProgressRing(
                              progress: hatim.progressPercentage / 100,
                              size: 120,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${hatim.progressPercentage.toStringAsFixed(1)}%',
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.deepSageGreen,
                                        ),
                                  ),
                                  Text(
                                    '${hatim.readPages} / ${hatim.totalPages}',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: AppTheme.softCharcoal.withOpacity(0.7),
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    ],
                    // Sadaqah/Support Section (Web User)
                    const SizedBox(height: 20),
                    _buildSadaqahSection(context),
                  ],
                ),
              ),
            ),
            );
          },
        ),
      );
    }

    // Firebase disabled - mobile mode removed
    // Show the same UI as web (local-only profile)
    return Scaffold(
      backgroundColor: AppTheme.warmCream,
      appBar: AppBar(
        title: Text(localizations?.profile ?? 'Profile'),
        backgroundColor: AppTheme.warmCream,
      ),
      body: Consumer<HatimProvider>(
        builder: (context, hatimProvider, _) {
          // Firebase disabled - use local profile only
          final displayName = settingsProvider.userName;
          final email = ''; // No email in local mode

          return SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Avatar
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: AppTheme.deepSageGreen,
                        child: Text(
                          displayName.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                            fontSize: 48,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Display Name
                      Text(
                        displayName,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: AppTheme.deepSageGreen,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),

                      const SizedBox(height: 16),

                      // Reading Progress
                      Consumer<HatimProvider>(
                        builder: (context, hatimProvider, child) {
                          final hatim = hatimProvider.activeHatim;
                          if (hatim == null) {
                            return const SizedBox.shrink();
                          }

                          return Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color: AppTheme.softCharcoal.withOpacity(0.1),
                                width: 0.5,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                children: [
                                  Text(
                                    'Reading Progress',
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          color: AppTheme.deepSageGreen,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  const SizedBox(height: 16),
                                  ProgressRing(
                                    progress: hatim.progressPercentage / 100,
                                    size: 120,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '${hatim.progressPercentage.toStringAsFixed(1)}%',
                                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                                color: AppTheme.deepSageGreen,
                                              ),
                                        ),
                                        Text(
                                          '${hatim.readPages} / ${hatim.totalPages}',
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                color: AppTheme.softCharcoal.withOpacity(0.7),
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 32),

                      // Sadaqah/Support Section
                      _buildSadaqahSection(context),
                      const SizedBox(height: 24),

                      // Sign Out Button (Local mode - no Firebase)
                      ElevatedButton.icon(
                        onPressed: () async {
                          // Local mode - no sign out needed
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Local mode - sign out not available'),
                                backgroundColor: AppTheme.deepSageGreen,
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.logout),
                        label: Text(localizations?.signOut ?? 'Sign Out'),
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
                );
              },
            ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildSadaqahSection(BuildContext context) {
    // Minimal version: Just a simple button that opens a dialog
    return OutlinedButton.icon(
      onPressed: () => _showSadaqahDialog(context),
      icon: const Icon(Icons.favorite, color: AppTheme.deepSageGreen),
      label: Text(
        'Support the Project (Sadaqah)',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.deepSageGreen,
              fontWeight: FontWeight.w600,
            ),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        side: BorderSide(
          color: AppTheme.deepSageGreen.withOpacity(0.3),
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showSadaqahDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.warmCream,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.favorite, color: AppTheme.deepSageGreen, size: 28),
            const SizedBox(width: 12),
            Text(
              'Support the Project',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.deepSageGreen,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Description
              Text(
                'Uygulamayı reklamsız ve ücretsiz tutmamıza destek olun. Bu bir sadaka-i cariyedir.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.softCharcoal.withOpacity(0.8),
                      height: 1.5,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                '(Every donation helps keep this app free and ad-free)',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.softCharcoal.withOpacity(0.6),
                      fontStyle: FontStyle.italic,
                    ),
              ),
              const SizedBox(height: 24),

              // Donation Tiers
              _buildDonationTier(
                context,
                productId: DonationService.smallSadaqah,
                title: 'Small Sadaqah',
                description: 'Buy us a coffee ☕',
                price: '\$1.00 / 30 TL',
              ),
              const SizedBox(height: 12),
              _buildDonationTier(
                context,
                productId: DonationService.mediumSadaqah,
                title: 'Medium Sadaqah',
                description: 'Support development 💚',
                price: '\$5.00 / 150 TL',
              ),
              const SizedBox(height: 12),
              _buildDonationTier(
                context,
                productId: DonationService.largeSadaqah,
                title: 'Large Sadaqah',
                description: 'Be a generous supporter 🌟',
                price: '\$10.00 / 300 TL',
              ),
              const SizedBox(height: 16),

              // Info text
              Text(
                '✨ Sadaqa Jariyah: Your support helps thousands read the Quran',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.deepSageGreen.withOpacity(0.8),
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Close',
              style: TextStyle(color: AppTheme.deepSageGreen),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDonationTier(
    BuildContext context, {
    required String productId,
    required String title,
    required String description,
    required String price,
  }) {
    return OutlinedButton(
      onPressed: () => _handleDonation(context, productId),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.all(16),
        side: BorderSide(
          color: AppTheme.deepSageGreen.withOpacity(0.3),
          width: 1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.deepSageGreen,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.softCharcoal.withOpacity(0.7),
                      ),
                ),
              ],
            ),
          ),
          Text(
            price,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.deepSageGreen,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleDonation(BuildContext context, String productId) async {
    if (kIsWeb) {
      // Show message that donations are only available on mobile
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Donations are only available on mobile (Android/iOS)'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      // Initialize donation service
      final donationService = DonationService();
      final isAvailable = await donationService.initialize();

      if (!isAvailable) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('In-App Purchase not available on this device'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Initiate purchase
      final success = await donationService.makeDonation(productId);

      if (context.mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Thank you for your support! 💚'),
              backgroundColor: AppTheme.deepSageGreen,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Purchase cancelled or failed'),
              backgroundColor: Colors.grey,
            ),
          );
        }
      }
    } catch (e) {
      print('[ProfileScreen] Donation error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showEditNameDialog(BuildContext context, SettingsProvider settingsProvider) {
    final TextEditingController nameController = TextEditingController(
      text: settingsProvider.userName,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.warmCream,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Edit Your Name',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.deepSageGreen,
                fontWeight: FontWeight.bold,
              ),
        ),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Enter your name',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.deepSageGreen),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.deepSageGreen, width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppTheme.softCharcoal.withOpacity(0.7)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = nameController.text.trim();
              if (newName.isNotEmpty) {
                settingsProvider.updateUserName(newName);
                Navigator.of(context).pop();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.deepSageGreen,
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
