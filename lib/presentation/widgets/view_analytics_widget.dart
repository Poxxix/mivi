import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mivi/core/services/view_analytics_service.dart';
import 'package:mivi/core/utils/haptic_utils.dart';

class ViewAnalyticsWidget extends StatefulWidget {
  const ViewAnalyticsWidget({super.key});

  @override
  State<ViewAnalyticsWidget> createState() => _ViewAnalyticsWidgetState();
}

class _ViewAnalyticsWidgetState extends State<ViewAnalyticsWidget>
    with SingleTickerProviderStateMixin {
  final ViewAnalyticsService _analyticsService = ViewAnalyticsService.instance;
  late TabController _tabController;

  Map<String, dynamic> _totalStats = {};
  List<ViewSession> _recentSessions = [];
  Map<String, int> _dailyViews = {};
  List<MapEntry<int, int>> _mostViewed = [];
  // ignore: unused_field
  List<MapEntry<int, int>> _mostWatched = [];
  Map<String, int> _viewTypeStats = {};

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAnalytics();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAnalytics() async {
    setState(() => _isLoading = true);

    try {
      _totalStats = _analyticsService.getTotalAnalytics();
      _recentSessions = _analyticsService.getRecentSessions(limit: 10);
      _dailyViews = _analyticsService.getDailyViewCounts(days: 7);
      _mostViewed = _analyticsService.getMostViewedMovies(limit: 5);
      _mostWatched = _analyticsService.getMostWatchedMovies(limit: 5);
      _viewTypeStats = _analyticsService.getViewTypeAnalytics();
    } catch (e) {
      print('Error loading analytics: $e');
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(
                  Icons.analytics,
                  color: colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Viewing Analytics',
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    HapticUtils.light();
                    _loadAnalytics();
                  },
                  icon: Icon(
                    Icons.refresh,
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),

          if (_isLoading)
            _buildLoadingState(colorScheme)
          else
            _buildAnalyticsContent(colorScheme),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1);
  }

  Widget _buildLoadingState(ColorScheme colorScheme) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading analytics...',
              style: TextStyle(
                color: colorScheme.onSurface.withOpacity(0.6),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsContent(ColorScheme colorScheme) {
    return Column(
      children: [
        // Tab bar
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TabBar(
            controller: _tabController,
            dividerColor: Colors.transparent,
            indicator: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            labelColor: Colors.white,
            unselectedLabelColor: colorScheme.onSurface.withOpacity(0.6),
            labelStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            tabs: const [
              Tab(text: 'Overview'),
              Tab(text: 'Activity'),
              Tab(text: 'Insights'),
            ],
          ),
        ),

        // Tab content
        SizedBox(
          height: 400,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(colorScheme),
              _buildActivityTab(colorScheme),
              _buildInsightsTab(colorScheme),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewTab(ColorScheme colorScheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick stats
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  colorScheme,
                  'Total Views',
                  '${_totalStats['totalViews'] ?? 0}',
                  Icons.visibility,
                  colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  colorScheme,
                  'Movies Watched',
                  '${_totalStats['uniqueMoviesViewed'] ?? 0}',
                  Icons.movie,
                  Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  colorScheme,
                  'Watch Time',
                  _formatDuration(_totalStats['totalViewTimeSeconds'] ?? 0),
                  Icons.access_time,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  colorScheme,
                  'Streak',
                  '${_analyticsService.getCurrentViewingStreak()} days',
                  Icons.local_fire_department,
                  Colors.red,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Weekly activity
          Text(
            'Weekly Activity',
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _buildWeeklyChart(colorScheme),
        ],
      ),
    );
  }

  Widget _buildActivityTab(ColorScheme colorScheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Activity',
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          if (_recentSessions.isEmpty)
            _buildEmptyState(colorScheme, 'No recent activity')
          else
            ..._recentSessions.map((session) => _buildSessionItem(session, colorScheme)),
        ],
      ),
    );
  }

  Widget _buildInsightsTab(ColorScheme colorScheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Most viewed
          Text(
            'Most Viewed Movies',
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          if (_mostViewed.isEmpty)
            _buildEmptyState(colorScheme, 'No viewing data yet')
          else
            ..._mostViewed.asMap().entries.map((entry) {
              final index = entry.key;
              final movieData = entry.value;
              return _buildTopMovieItem(
                colorScheme,
                index + 1,
                'Movie ${movieData.key}',
                '${movieData.value} views',
                Icons.visibility,
              );
            }),

          const SizedBox(height: 24),

          // View types
          Text(
            'View Types',
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _buildViewTypesChart(colorScheme),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    ColorScheme colorScheme,
    String title,
    String value,
    IconData icon,
    Color iconColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: colorScheme.onSurface.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart(ColorScheme colorScheme) {
    final maxViews = _dailyViews.values.isNotEmpty 
        ? _dailyViews.values.reduce((a, b) => a > b ? a : b)
        : 1;

    return Container(
      height: 120,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: _dailyViews.entries.map((entry) {
          final date = DateTime.parse(entry.key);
          final views = entry.value;
          final height = maxViews > 0 ? (views / maxViews) * 80 : 0.0;

          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: 20,
                height: height,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][date.weekday - 1],
                style: TextStyle(
                  color: colorScheme.onSurface.withOpacity(0.6),
                  fontSize: 10,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSessionItem(ViewSession session, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            _getViewTypeIcon(session.viewType),
            color: _getViewTypeColor(session.viewType),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.movieTitle,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${session.viewType} • ${_formatDuration(session.viewDurationSeconds)}',
                  style: TextStyle(
                    color: colorScheme.onSurface.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _formatTimeAgo(session.startTime),
            style: TextStyle(
              color: colorScheme.onSurface.withOpacity(0.5),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopMovieItem(
    ColorScheme colorScheme,
    int rank,
    String title,
    String subtitle,
    IconData icon,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: rank <= 3 ? Colors.amber : colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$rank',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: colorScheme.onSurface.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            icon,
            color: colorScheme.onSurface.withOpacity(0.5),
            size: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildViewTypesChart(ColorScheme colorScheme) {
    final total = _viewTypeStats.values.fold(0, (a, b) => a + b);
    if (total == 0) {
      return _buildEmptyState(colorScheme, 'No view data available');
    }

    return Column(
      children: _viewTypeStats.entries.map((entry) {
        final percentage = (entry.value / total * 100).round();
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Icon(
                _getViewTypeIcon(entry.key),
                color: _getViewTypeColor(entry.key),
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          entry.key.toUpperCase(),
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '$percentage%',
                          style: TextStyle(
                            color: colorScheme.onSurface.withOpacity(0.6),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: entry.value / total,
                      backgroundColor: colorScheme.surfaceVariant.withOpacity(0.3),
                      valueColor: AlwaysStoppedAnimation<Color>(_getViewTypeColor(entry.key)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme, String message) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 48,
              color: colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                color: colorScheme.onSurface.withOpacity(0.6),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getViewTypeIcon(String viewType) {
    switch (viewType) {
      case 'detail':
        return Icons.info_outline;
      case 'trailer':
        return Icons.play_circle_outline;
      case 'full_movie':
        return Icons.movie;
      default:
        return Icons.visibility;
    }
  }

  Color _getViewTypeColor(String viewType) {
    switch (viewType) {
      case 'detail':
        return Colors.blue;
      case 'trailer':
        return Colors.orange;
      case 'full_movie':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${secs}s';
    } else {
      return '${secs}s';
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
} 