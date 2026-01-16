import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/hatim_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/language_provider.dart';
import '../services/firebase_auth_service.dart';
import '../services/sync_service.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _hatimNameController = TextEditingController();
  bool _isSyncing = false;

  @override
  void dispose() {
    _hatimNameController.dispose();
    super.dispose();
  }

  void _showCreateHatimDialog(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    _hatimNameController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.createNewHatim),
        content: TextField(
          controller: _hatimNameController,
          decoration: InputDecoration(
            labelText: localizations.hatimName,
            hintText: 'e.g., Ramadan 2026',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localizations.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              if (_hatimNameController.text.isNotEmpty) {
                Provider.of<HatimProvider>(context, listen: false)
                    .createHatim(_hatimNameController.text);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${localizations.createNewHatim} ${localizations.completed}')),
                );
              }
            },
            child: Text(localizations.create),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSync(BuildContext context) async {
    final localizations = AppLocalizations.of(context)!;
    final syncService = Provider.of<SyncService?>(context, listen: false);
    
    if (syncService == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sync is not available on web. Use mobile app.')),
      );
      return;
    }
    
    if (!syncService.isSignedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please sign in to sync')),
      );
      return;
    }

    setState(() {
      _isSyncing = true;
    });

    final success = await syncService.sync();
    
    setState(() {
      _isSyncing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? localizations.syncComplete : 'Sync failed'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isRTL = languageProvider.isRTL;

    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(localizations.settingsTitle),
        ),
        body: Consumer2<HatimProvider, SettingsProvider>(
          builder: (context, hatimProvider, settingsProvider, child) {
            final authService = Provider.of<FirebaseAuthService?>(context, listen: false);
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Authentication Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Authentication',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        if (authService != null && authService.isSignedIn) ...[
                          Text('Signed in as: ${authService.currentUser?.email ?? "Anonymous"}'),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: () async {
                              await authService.signOut();
                              setState(() {});
                            },
                            icon: const Icon(Icons.logout),
                            label: Text(localizations.signOut),
                          ),
                        ] else if (authService != null) ...[
                          ElevatedButton.icon(
                            onPressed: () async {
                              await authService.signInWithGoogle();
                              setState(() {});
                            },
                            icon: const Icon(Icons.login),
                            label: Text(localizations.signInWithGoogle),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: () async {
                              await authService.signInAnonymously();
                              setState(() {});
                            },
                            icon: const Icon(Icons.person_outline),
                            label: Text(localizations.signInAnonymously),
                          ),
                        ] else ...[
                          Text('Firebase authentication is not available on web. Use mobile app for sync.', style: Theme.of(context).textTheme.bodySmall),
                        ],
                        if (authService != null && authService.isSignedIn) ...[
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _isSyncing ? null : () => _handleSync(context),
                            icon: _isSyncing 
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.sync),
                            label: Text(_isSyncing ? localizations.syncing : localizations.sync),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Language Selection
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          localizations.languageSelection,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        RadioListTile<String>(
                          title: Text(localizations.english),
                          value: 'en',
                          groupValue: languageProvider.locale.languageCode,
                          onChanged: (value) {
                            if (value != null) {
                              languageProvider.setLanguage(value);
                            }
                          },
                        ),
                        RadioListTile<String>(
                          title: Text(localizations.turkish),
                          value: 'tr',
                          groupValue: languageProvider.locale.languageCode,
                          onChanged: (value) {
                            if (value != null) {
                              languageProvider.setLanguage(value);
                            }
                          },
                        ),
                        RadioListTile<String>(
                          title: Text(localizations.arabic),
                          value: 'ar',
                          groupValue: languageProvider.locale.languageCode,
                          onChanged: (value) {
                            if (value != null) {
                              languageProvider.setLanguage(value);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Hatim Management Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          localizations.hatimManagement,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => _showCreateHatimDialog(context),
                          icon: const Icon(Icons.add),
                          label: Text(localizations.createNewHatim),
                        ),
                        const SizedBox(height: 16),
                        ...hatimProvider.hatims.map((hatim) => ListTile(
                              title: Text(hatim.name),
                              subtitle: Text(
                                '${hatim.progressPercentage.toStringAsFixed(1)}% ${localizations.completed}',
                              ),
                              trailing: hatim.isActive
                                  ? Icon(Icons.check_circle, color: AppTheme.accentGreen)
                                  : null,
                              onTap: () {
                                hatimProvider.setActiveHatim(hatim.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${hatim.name} ${localizations.completed}'),
                                  ),
                                );
                              },
                              onLongPress: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text(localizations.deleteHatim),
                                    content: Text(localizations.deleteHatimConfirm),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text(localizations.cancel),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          hatimProvider.deleteHatim(hatim.id);
                                          Navigator.pop(context);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text(localizations.delete)),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                        ),
                                        child: Text(localizations.delete),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            )),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Reading Settings
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          localizations.readingSettings,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          title: Text(localizations.fullScreenMode),
                          subtitle: Text('Hide all UI elements'),
                          trailing: Switch(
                            value: settingsProvider.fullFocusMode,
                            onChanged: (value) {
                              settingsProvider.updateFullFocusMode(value);
                            },
                          ),
                        ),
                        ListTile(
                          title: Text(localizations.fontSize),
                          subtitle: Text('${settingsProvider.fontSize.toInt()}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: () {
                                  if (settingsProvider.fontSize > 12) {
                                    settingsProvider.updateFontSize(
                                        settingsProvider.fontSize - 2);
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () {
                                  if (settingsProvider.fontSize < 32) {
                                    settingsProvider.updateFontSize(
                                        settingsProvider.fontSize + 2);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Notifications Settings
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          localizations.notifications,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          title: Text(localizations.dailyReminder),
                          subtitle: Text('Receive daily reading reminder'),
                          trailing: Switch(
                            value: settingsProvider.notificationsEnabled,
                            onChanged: (value) {
                              settingsProvider.updateNotificationsEnabled(value);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
