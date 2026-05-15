import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/database_service.dart';
import '../../theme.dart';
import '../../l10n/app_localizations.dart';
import 'user_home_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _total = 0, _pending = 0, _resolved = 0, _inProgress = 0;
  bool _loading = true;
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _loading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('userId') ?? '';
      final name = prefs.getString('name') ?? '';

      debugPrint('Dashboard - Loading stats for UID: $uid');

      if (uid.isEmpty) {
        debugPrint('Dashboard - No user ID found!');
        setState(() {
          _userName = name;
          _loading = false;
        });
        return;
      }

      final reports =
          await DatabaseService.instance.getUserReportsStream(uid).first;

      debugPrint('Dashboard - Found ${reports.length} reports');
      for (var report in reports) {
        debugPrint('Report status: "${report.status}"');
      }

      setState(() {
        _userName = name;
        _total = reports.length;
        // Case-insensitive status matching
        _pending =
            reports.where((r) => r.status.toLowerCase() == 'pending').length;
        _resolved =
            reports.where((r) => r.status.toLowerCase() == 'resolved').length;
        _inProgress =
            reports
                .where(
                  (r) =>
                      r.status.toLowerCase() == 'in progress' ||
                      r.status.toLowerCase() == 'in_progress',
                )
                .length;

        debugPrint(
          'Stats - Total: $_total, Pending: $_pending, Resolved: $_resolved, In Progress: $_inProgress',
        );
        _loading = false;
      });
    } catch (e) {
      debugPrint('Error loading stats: $e');
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: RefreshIndicator(
        onRefresh: _loadStats,
        color: AppTheme.primary,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 180,
              pinned: true,
              stretch: true,
              backgroundColor: AppTheme.primary,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: AppTheme.headerGradient,
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Logo - clickable to stay on home
                              GestureDetector(
                                onTap: () {
                                  // Navigate to home tab
                                  final userHomeState =
                                      context
                                          .findAncestorStateOfType<
                                            UserHomeScreenState
                                          >();
                                  userHomeState?.navigateToTab(0);
                                },
                                child: Image.asset(
                                  'assets/logof.png',
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.welcomeUser,
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: 0.85,
                                        ),
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _userName.isNotEmpty
                                          ? _userName
                                          : l10n.home,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child:
                  _loading
                      ? Padding(
                        padding: const EdgeInsets.only(top: 80),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.primary,
                          ),
                        ),
                      )
                      : Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Stats grid
                            LayoutBuilder(
                              builder: (context, constraints) {
                                // Adjust aspect ratio based on screen width
                                double aspectRatio;
                                if (constraints.maxWidth < 360) {
                                  aspectRatio = 1.4;
                                } else if (constraints.maxWidth < 400) {
                                  aspectRatio = 1.5;
                                } else {
                                  aspectRatio = 1.6;
                                }
                                
                                return GridView.count(
                                  crossAxisCount: 2,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: aspectRatio,
                                  children: [
                                    _StatCard(
                                      label: l10n.total,
                                      value: _total,
                                      icon: Icons.description_rounded,
                                      color: AppTheme.primary,
                                    ),
                                    _StatCard(
                                      label: l10n.pending,
                                      value: _pending,
                                      icon: Icons.hourglass_top_rounded,
                                      color: AppTheme.warning,
                                    ),
                                    _StatCard(
                                      label: l10n.inProgress,
                                      value: _inProgress,
                                      icon: Icons.autorenew_rounded,
                                      color: AppTheme.purple,
                                    ),
                                    _StatCard(
                                      label: l10n.resolved,
                                      value: _resolved,
                                      icon: Icons.check_circle_rounded,
                                      color: AppTheme.success,
                                    ),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 24),
                            Text(
                              l10n.selectProblemType,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _QuickActionCard(
                              icon: Icons.add_circle_outline_rounded,
                              iconColor: AppTheme.primary,
                              title: l10n.reportProblem,
                              subtitle: l10n.whatProblem,
                              onTap: () {
                                // Navigate to services screen (tab index 1)
                                final homeState =
                                    context
                                        .findAncestorStateOfType<
                                          State<StatefulWidget>
                                        >();
                                if (homeState != null &&
                                    homeState is State &&
                                    homeState.mounted) {
                                  // Access the parent UserHomeScreen's navigation
                                  final userHomeState =
                                      context
                                          .findAncestorStateOfType<
                                            UserHomeScreenState
                                          >();
                                  userHomeState?.navigateToTab(1);
                                }
                              },
                            ),
                            const SizedBox(height: 24),
                            // Status legend
                            Text(
                              l10n.status,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _StatusLegend(l10n: l10n),
                          ],
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 4),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value.toString(),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: color,
                      height: 1.0,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _QuickActionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.cardBg,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.border),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: AppTheme.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusLegend extends StatelessWidget {
  final AppLocalizations l10n;
  const _StatusLegend({required this.l10n});

  @override
  Widget build(BuildContext context) {
    final items = [
      (l10n.pending, AppTheme.warning),
      (l10n.inProgress, AppTheme.purple),
      (l10n.resolved, AppTheme.success),
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children:
            items
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: item.$2,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          item.$1,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
      ),
    );
  }
}
