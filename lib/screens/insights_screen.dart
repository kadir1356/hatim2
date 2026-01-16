import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/insights_provider.dart';
import '../providers/language_provider.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isRTL = languageProvider.isRTL;

    return Directionality(
      textDirection: isRTL ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(localizations.insightsTitle),
        ),
        body: Consumer<InsightsProvider>(
          builder: (context, insightsProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Streak Card with Glowing Lantern
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppTheme.warmCream,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AppTheme.lightSageGreen.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      // Glowing Lantern Icon
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.deepSageGreen.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.local_fire_department,
                          size: 56,
                          color: AppTheme.deepSageGreen,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        '${insightsProvider.currentStreak}',
                        style: AppTheme.uiTextStyle(
                          fontSize: 56,
                          fontWeight: FontWeight.w300,
                          color: AppTheme.deepSageGreen,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${localizations.dailyStreak}',
                        style: AppTheme.uiTextStyle(
                          fontSize: 16,
                          color: AppTheme.softCharcoal.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Stats Cards - Minimalist
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: localizations.total,
                        value: insightsProvider.getTotalPagesRead().toString(),
                        icon: Icons.menu_book,
                        color: AppTheme.deepSageGreen,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _StatCard(
                        title: localizations.thisMonth,
                        value: insightsProvider.getPagesReadThisMonth().toString(),
                        icon: Icons.calendar_month,
                        color: AppTheme.mediumSageGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Heat Map
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          localizations.last30Days,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        _HeatMapWidget(
                          heatMapData: insightsProvider.heatMapData,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
          },
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
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
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTheme.uiTextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w300,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTheme.uiTextStyle(
              fontSize: 13,
              color: AppTheme.softCharcoal.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeatMapWidget extends StatelessWidget {
  final Map<DateTime, int> heatMapData;

  const _HeatMapWidget({required this.heatMapData});

  Color _getColorForValue(int value) {
    if (value == 0) return AppTheme.lightSageGreen;
    if (value < 3) return AppTheme.accentGreen.withOpacity(0.5);
    if (value < 5) return AppTheme.accentGreen;
    return AppTheme.darkSageGreen;
  }

  @override
  Widget build(BuildContext context) {
    final dates = heatMapData.keys.toList()..sort();
    
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: dates.map((date) {
        final value = heatMapData[date] ?? 0;
        return Tooltip(
          message: '${DateFormat('dd/MM').format(date)}: $value sayfa',
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: _getColorForValue(value),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      }).toList(),
    );
  }
}
