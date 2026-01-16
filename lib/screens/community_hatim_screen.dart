import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/community_hatim.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import 'reading_screen.dart';

class CommunityHatimScreen extends StatefulWidget {
  const CommunityHatimScreen({super.key});

  @override
  State<CommunityHatimScreen> createState() => _CommunityHatimScreenState();
}

class _CommunityHatimScreenState extends State<CommunityHatimScreen> {
  FirebaseFirestore? get _firestore => kIsWeb ? null : FirebaseFirestore.instance;
  String? _communityHatimId;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _initializeCommunityHatim();
    } else {
      // Web'de Firestore çalışmıyor - placeholder data göster
      setState(() {
        _isLoading = false;
        _errorMessage = 'Community Hatim is only available on mobile devices.';
      });
    }
  }

  Future<void> _initializeCommunityHatim() async {
    if (kIsWeb || _firestore == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Community Hatim is only available on mobile devices.';
      });
      return;
    }
    
    try {
      final snapshot = await _firestore!
          .collection('community_hatims')
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          _communityHatimId = snapshot.docs.first.id;
          _isLoading = false;
        });
      } else {
        await _createDefaultCommunityHatim();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading community hatim: ${e.toString()}';
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _createDefaultCommunityHatim() async {
    if (kIsWeb || _firestore == null) {
      setState(() {
        _errorMessage = 'Community Hatim is only available on mobile devices.';
      });
      return;
    }

    try {
      final juzStatus = <String, String>{};
      for (int i = 1; i <= 30; i++) {
        juzStatus[i.toString()] = 'empty';
      }

      final newHatim = CommunityHatim(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Community Hatim',
        juzStatus: juzStatus,
        createdAt: DateTime.now(),
      );

      final docRef = await _firestore!.collection('community_hatims').add(newHatim.toJson());
      setState(() {
        _communityHatimId = docRef.id;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error creating community hatim: ${e.toString()}';
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _claimJuz(int juzNumber) async {
    if (kIsWeb || _firestore == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Community features are only available on mobile devices.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (kIsWeb || _firestore == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Community features are only available on mobile devices.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _communityHatimId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please sign in to claim a Juz'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    try {
      final docRef = _firestore!.collection('community_hatims').doc(_communityHatimId);
      final doc = await docRef.get();
      
      if (!doc.exists) {
        await _initializeCommunityHatim();
        return;
      }

      final data = doc.data()!;
      final currentHatim = CommunityHatim.fromJson({
        'id': doc.id,
        ...data,
      });
      
      final juzKey = juzNumber.toString();
      final currentStatus = currentHatim.getJuzStatus(juzNumber);

      if (currentStatus == 'empty') {
        // Claim juz
        final updatedJuzStatus = Map<String, String>.from(currentHatim.juzStatus);
        updatedJuzStatus[juzKey] = user.uid;

        await docRef.update({
          'juzStatus': updatedJuzStatus,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Juz $juzNumber claimed! Navigating to reading...'),
              backgroundColor: AppTheme.deepSageGreen,
              duration: const Duration(seconds: 2),
            ),
          );
          
          // Navigate to ReadingScreen for this Juz
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReadingScreen.forCommunityJuz(
                    juzNumber: juzNumber,
                    communityHatimId: _communityHatimId!,
                  ),
                ),
              );
            }
          });
        }
      } else if (currentStatus == user.uid) {
        // Mark as completed
        final updatedJuzStatus = Map<String, String>.from(currentHatim.juzStatus);
        updatedJuzStatus[juzKey] = 'completed_${user.uid}';

        await docRef.update({
          'juzStatus': updatedJuzStatus,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Juz $juzNumber completed!'),
              backgroundColor: AppTheme.accentGreen,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('This Juz is already claimed by another user'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
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

  Color _getJuzColor(CommunityHatim hatim, int juzNumber) {
    final status = hatim.getJuzStatus(juzNumber);
    final user = kIsWeb ? null : FirebaseAuth.instance.currentUser;

    if (status == 'empty') {
      return AppTheme.warmCream;
    } else if (status.startsWith('completed_')) {
      return const Color(0xFFD32F2F); // Deep Amber/Soft Red
    } else if (status == user?.uid) {
      return AppTheme.deepSageGreen; // Reading
    } else {
      return AppTheme.accentGreen; // Someone else is reading
    }
  }

  Widget _getJuzWidget(CommunityHatim hatim, int juzNumber) {
    final status = hatim.getJuzStatus(juzNumber);
    final user = kIsWeb ? null : FirebaseAuth.instance.currentUser;
    final isMine = status == user?.uid || status.startsWith('completed_${user?.uid}');
    final isEmpty = status == 'empty';
    final isCompleted = status.startsWith('completed_');

    return GestureDetector(
      onTap: () {
        if (isEmpty || isMine) {
          _claimJuz(juzNumber);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: _getJuzColor(hatim, juzNumber),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isMine
                ? AppTheme.deepSageGreen
                : AppTheme.softCharcoal.withOpacity(0.2),
            width: isMine ? 2 : 1,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isEmpty)
                Text(
                  '$juzNumber',
                  style: TextStyle(
                    color: AppTheme.softCharcoal,
                    fontWeight: FontWeight.bold,
                  ),
                )
              else if (isCompleted)
                Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 24,
                )
              else
                CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.white,
                  child: Text(
                    user?.displayName?.substring(0, 1).toUpperCase() ?? 'U',
                    style: TextStyle(
                      color: AppTheme.deepSageGreen,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              if (!isEmpty && !isCompleted)
                Text(
                  'Juz $juzNumber',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppTheme.warmCream,
      appBar: AppBar(
        title: Text(localizations?.communityHatim ?? 'Community Hatim'),
        backgroundColor: AppTheme.warmCream,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _initializeCommunityHatim,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.deepSageGreen,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : kIsWeb
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 64,
                            color: AppTheme.softCharcoal.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Community Hatim',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: AppTheme.deepSageGreen,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Text(
                              'Community features are only available on mobile devices. Please use the mobile app to join community hatims.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.softCharcoal.withOpacity(0.7),
                                  ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : _communityHatimId == null
                      ? Center(
                          child: ElevatedButton(
                            onPressed: _createDefaultCommunityHatim,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.deepSageGreen,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Create Community Hatim'),
                          ),
                        )
                      : _firestore == null
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.people_outline,
                                    size: 64,
                                    color: AppTheme.softCharcoal.withOpacity(0.5),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Community Hatim',
                                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                          color: AppTheme.deepSageGreen,
                                        ),
                                  ),
                                  const SizedBox(height: 8),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 32),
                                    child: Text(
                                      'Community features are only available on mobile devices.',
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: AppTheme.softCharcoal.withOpacity(0.7),
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : StreamBuilder<DocumentSnapshot>(
                              stream: _firestore!
                                  .collection('community_hatims')
                                  .doc(_communityHatimId)
                                  .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (!snapshot.hasData || !snapshot.data!.exists) {
                          return Center(
                            child: ElevatedButton(
                              onPressed: _createDefaultCommunityHatim,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.deepSageGreen,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Create Community Hatim'),
                            ),
                          );
                        }

                        final data = snapshot.data!.data() as Map<String, dynamic>;
                        final hatim = CommunityHatim.fromJson({
                          'id': snapshot.data!.id,
                          ...data,
                        });

                        return SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title
                              Text(
                                hatim.title,
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      color: AppTheme.deepSageGreen,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap an empty Juz to claim it, tap your Juz to mark as completed',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppTheme.softCharcoal.withOpacity(0.7),
                                    ),
                              ),
                              const SizedBox(height: 24),

                              // 6x5 Grid (30 Juz)
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 6,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                  childAspectRatio: 1.0,
                                ),
                                itemCount: 30,
                                itemBuilder: (context, index) {
                                  return _getJuzWidget(hatim, index + 1);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
    );
  }
}
