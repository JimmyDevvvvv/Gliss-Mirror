import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/theme/design_system.dart';
import 'package:frontend/core/theme/gliss_ui.dart';
import 'package:go_router/go_router.dart';
import 'models/analysis_record.dart';

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverTabBarDelegate(this.tabBar);

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: AppTheme.pureWhite, child: tabBar);
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(covariant _SliverTabBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar;
  }
}

class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key});

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with actual data from provider
    final bool hasData = true; // Using mock data for now
    final List<AnalysisRecord> records = _getMockData();

    return Scaffold(
      backgroundColor: AppTheme.lightGrey,
      body: CustomScrollView(
        slivers: [
          // Premium gradient app bar
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            backgroundColor: AppTheme.sageGreen,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.sageGreen, AppTheme.brightMint],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.all(DesignTokens.spacing2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Progress Tracker',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.pureWhite,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          hasData
                              ? 'Track your hair transformation journey'
                              : 'Start your journey to healthier hair',
                          style: TextStyle(
                            fontSize: 15,
                            color: AppTheme.pureWhite.withOpacity(0.9),
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Tab bar
          if (hasData)
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverTabBarDelegate(
                TabBar(
                  controller: _tabController,
                  indicatorColor: AppTheme.henkelRed,
                  indicatorWeight: 3,
                  labelColor: AppTheme.darkBlue,
                  unselectedLabelColor: AppTheme.darkBlue.withOpacity(0.5),
                  labelStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                  tabs: const [
                    Tab(text: 'Timeline'),
                    Tab(text: 'Statistics'),
                  ],
                ),
              ),
            ),

          // Content
          SliverToBoxAdapter(
            child: hasData
                ? _buildContentWithData(records)
                : _buildEmptyState(context),
          ),
        ],
      ),
      floatingActionButton: hasData
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/camera'),
              backgroundColor: AppTheme.henkelRed,
              icon: const Icon(Icons.camera_alt_rounded),
              label: const Text(
                'New Scan',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            )
          : null,
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(DesignTokens.spacing3),
      child: Column(
        children: [
          SizedBox(height: DesignTokens.spacing4),

          // Illustration card
          GlissUI.card(
            padding: EdgeInsets.all(DesignTokens.spacing4),
            backgroundColor: AppTheme.pureWhite,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.softMint.withOpacity(0.3),
                        AppTheme.softBlue.withOpacity(0.3),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.timeline_rounded,
                    size: 80,
                    color: AppTheme.sageGreen,
                  ),
                ),
                SizedBox(height: DesignTokens.spacing3),
                const Text(
                  'No Progress Yet',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.darkBlue,
                  ),
                ),
                SizedBox(height: DesignTokens.spacing1),
                Text(
                  'Start tracking your hair health journey by taking your first analysis',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: AppTheme.darkBlue.withOpacity(0.7),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: DesignTokens.spacing3),

          // Benefits cards
          const Text(
            'Why Track Your Progress?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.darkBlue,
            ),
          ),
          SizedBox(height: DesignTokens.spacing2),

          GlissUI.infoCard(
            icon: Icons.trending_up_rounded,
            title: 'See Real Improvements',
            description:
                'Watch your hair health score improve over time with consistent care',
            iconColor: AppTheme.sageGreen,
          ),

          SizedBox(height: DesignTokens.spacing2),

          GlissUI.infoCard(
            icon: Icons.camera_alt_rounded,
            title: 'Visual Comparisons',
            description:
                'Compare before and after photos to see your transformation',
            iconColor: AppTheme.freshBlue,
          ),

          SizedBox(height: DesignTokens.spacing2),

          GlissUI.infoCard(
            icon: Icons.show_chart_rounded,
            title: 'Track Each Metric',
            description:
                'Monitor frizz, dryness, and damage levels individually',
            iconColor: AppTheme.deepViolet,
          ),

          SizedBox(height: DesignTokens.spacing4),

          // CTA Button
          GlissUI.primaryButton(
            text: 'Take Your First Analysis',
            icon: Icons.camera_alt_rounded,
            onPressed: () => context.push('/camera'),
            fullWidth: true,
          ),

          SizedBox(height: DesignTokens.spacing2),

          Text(
            'Takes less than 30 seconds',
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.darkBlue.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentWithData(List<AnalysisRecord> records) {
    return TabBarView(
      controller: _tabController,
      children: [_buildTimelineView(records), _buildStatisticsView(records)],
    );
  }

  Widget _buildTimelineView(List<AnalysisRecord> records) {
    return Padding(
      padding: EdgeInsets.all(DesignTokens.spacing2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: DesignTokens.spacing2),

          // Overall progress card
          GlissUI.progressComparison(
            previousScore: records.last.overallScore,
            currentScore: records.first.overallScore,
            timeframe: _calculateTimeframe(
              records.first.date,
              records.last.date,
            ),
          ),

          SizedBox(height: DesignTokens.spacing3),

          const Text(
            'Analysis History',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.darkBlue,
            ),
          ),

          SizedBox(height: DesignTokens.spacing2),

          // Timeline list
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: records.length,
            separatorBuilder: (context, index) =>
                SizedBox(height: DesignTokens.spacing2),
            itemBuilder: (context, index) {
              final record = records[index];
              final isLatest = index == 0;

              return _buildTimelineCard(record, isLatest);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineCard(AnalysisRecord record, bool isLatest) {
    final Color scoreColor = GlissUI.getDamageColor(record.overallScore);

    return GlissUI.card(
      onTap: () {
        // TODO: Navigate to detailed view
      },
      enableHoverEffect: true,
      padding: EdgeInsets.all(DesignTokens.spacing2),
      elevation: isLatest ? DesignTokens.elevation2 : DesignTokens.elevation1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Score indicator
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: scoreColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      record.overallScore.toString(),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: scoreColor,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '/10',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: scoreColor.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: DesignTokens.spacing2),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          _formatDate(record.date),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.darkBlue,
                          ),
                        ),
                        if (isLatest) ...[
                          SizedBox(width: DesignTokens.spacing1),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.brightMint,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'LATEST',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.deepGreen,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getTimeAgo(record.date),
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.darkBlue.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),

              Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.darkBlue.withOpacity(0.3),
              ),
            ],
          ),

          SizedBox(height: DesignTokens.spacing2),

          // Quick stats
          Row(
            children: [
              _buildQuickStat(
                'Frizz',
                record.frizzScore,
                Icons.water_drop_outlined,
              ),
              SizedBox(width: DesignTokens.spacing2),
              _buildQuickStat(
                'Dryness',
                record.drynessScore,
                Icons.wb_sunny_outlined,
              ),
              SizedBox(width: DesignTokens.spacing2),
              _buildQuickStat(
                'Damage',
                record.damageScore,
                Icons.healing_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(String label, int value, IconData icon) {
    final Color color = GlissUI.getDamageColor(value);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.darkBlue.withOpacity(0.7),
                    ),
                  ),
                  Text(
                    value.toString(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: color,
                      height: 1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsView(List<AnalysisRecord> records) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(DesignTokens.spacing2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: DesignTokens.spacing2),

          // Summary stats
          const Text(
            'Overview',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.darkBlue,
            ),
          ),
          SizedBox(height: DesignTokens.spacing2),

          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Scans',
                  records.length.toString(),
                  Icons.camera_alt_rounded,
                  AppTheme.freshBlue,
                ),
              ),
              SizedBox(width: DesignTokens.spacing2),
              Expanded(
                child: _buildStatCard(
                  'Avg Score',
                  _calculateAverageScore(records).toStringAsFixed(1),
                  Icons.star_rounded,
                  AppTheme.electricYellow,
                ),
              ),
            ],
          ),

          SizedBox(height: DesignTokens.spacing3),

          // Trend analysis
          const Text(
            'Metrics Breakdown',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.darkBlue,
            ),
          ),
          SizedBox(height: DesignTokens.spacing2),

          GlissUI.damageBreakdownCard(
            title: 'Frizz Level',
            score: records.first.frizzScore,
            icon: Icons.water_drop_outlined,
            description: _getTrendText(
              records.first.frizzScore,
              records.last.frizzScore,
            ),
          ),

          SizedBox(height: DesignTokens.spacing2),

          GlissUI.damageBreakdownCard(
            title: 'Dryness Level',
            score: records.first.drynessScore,
            icon: Icons.wb_sunny_outlined,
            description: _getTrendText(
              records.first.drynessScore,
              records.last.drynessScore,
            ),
          ),

          SizedBox(height: DesignTokens.spacing2),

          GlissUI.damageBreakdownCard(
            title: 'Damage Level',
            score: records.first.damageScore,
            icon: Icons.healing_outlined,
            description: _getTrendText(
              records.first.damageScore,
              records.last.damageScore,
            ),
          ),

          SizedBox(height: DesignTokens.spacing3),

          // Achievement card
          GlissUI.card(
            padding: EdgeInsets.all(DesignTokens.spacing3),
            backgroundColor: AppTheme.brightMint.withOpacity(0.2),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.sageGreen, AppTheme.brightMint],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.emoji_events_rounded,
                    color: AppTheme.pureWhite,
                    size: 28,
                  ),
                ),
                SizedBox(width: DesignTokens.spacing2),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Keep It Up!',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.darkBlue,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'You\'ve completed ${records.length} analyses. Consistency is key!',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.darkBlue.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return GlissUI.card(
      padding: EdgeInsets.all(DesignTokens.spacing2),
      backgroundColor: color.withOpacity(0.1),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          SizedBox(height: DesignTokens.spacing1),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: color,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.darkBlue.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  List<AnalysisRecord> _getMockData() {
    // TODO: Replace with actual data
    return [
      AnalysisRecord(
        date: DateTime.now(),
        overallScore: 5,
        frizzScore: 6,
        drynessScore: 5,
        damageScore: 4,
      ),
      AnalysisRecord(
        date: DateTime.now().subtract(const Duration(days: 7)),
        overallScore: 7,
        frizzScore: 8,
        drynessScore: 7,
        damageScore: 6,
      ),
    ];
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) return 'Today';
    if (difference.inDays == 1) return 'Yesterday';
    if (difference.inDays < 7) return '${difference.inDays} days ago';
    if (difference.inDays < 30)
      return '${(difference.inDays / 7).floor()} weeks ago';
    return '${(difference.inDays / 30).floor()} months ago';
  }

  String _calculateTimeframe(DateTime start, DateTime end) {
    final difference = end.difference(start);
    if (difference.inDays < 7) return '${difference.inDays} days';
    if (difference.inDays < 30)
      return '${(difference.inDays / 7).floor()} weeks';
    return '${(difference.inDays / 30).floor()} months';
  }

  double _calculateAverageScore(List<AnalysisRecord> records) {
    if (records.isEmpty) return 0;
    final sum = records.fold<int>(
      0,
      (sum, record) => sum + record.overallScore,
    );
    return sum / records.length;
  }

  String _getTrendText(int current, int previous) {
    final diff = current - previous;
    if (diff == 0) return 'No change';
    if (diff < 0) return '${diff.abs()} points better';
    return '$diff points higher';
  }
}

// Data model
class AnalysisRecord {
  final DateTime date;
  final int overallScore;
  final int frizzScore;
  final int drynessScore;
  final int damageScore;

  AnalysisRecord({
    required this.date,
    required this.overallScore,
    required this.frizzScore,
    required this.drynessScore,
    required this.damageScore,
  });
}
