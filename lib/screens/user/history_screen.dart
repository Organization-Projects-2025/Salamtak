import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../../services/database_service.dart';
import '../../models/report.dart';
import '../../theme.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/report_image_widget.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String? _nationalId;

  @override
  void initState() {
    super.initState();
    _loadNationalId();
  }

  Future<void> _loadNationalId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nationalId = prefs.getString('nationalId') ?? '';
    });
  }

  Color _statusColor(String status) {
    final lowerStatus = status.toLowerCase(); // Handle both cases
    switch (lowerStatus) {
      case 'pending':
        return AppTheme.warning;
      case 'in_progress':
      case 'in progress':
        return AppTheme.purple;
      case 'resolved':
        return AppTheme.success;
      default:
        return AppTheme.textSecondary;
    }
  }

  IconData _statusIcon(String status) {
    final lowerStatus = status.toLowerCase(); // Handle both cases
    switch (lowerStatus) {
      case 'pending':
        return Icons.hourglass_top_rounded;
      case 'in_progress':
      case 'in progress':
        return Icons.autorenew_rounded;
      case 'resolved':
        return Icons.check_circle_rounded;
      default:
        return Icons.circle_outlined;
    }
  }

  String _formatStatus(String status, BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final lowerStatus = status.toLowerCase(); // Handle both cases
    switch (lowerStatus) {
      case 'pending':
        return l10n.pending;
      case 'in_progress':
      case 'in progress':
        return l10n.inProgress;
      case 'resolved':
        return l10n.resolved;
      default:
        return status
            .split('_')
            .map((w) => w[0].toUpperCase() + w.substring(1))
            .join(' ');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // If national ID not loaded yet, show loading
    if (_nationalId == null) {
      return Scaffold(
        backgroundColor: AppTheme.surface,
        body: const Center(
          child: CircularProgressIndicator(color: AppTheme.primary),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: StreamBuilder<List<Report>>(
        stream: DatabaseService.instance.getUserReportsByNationalId(
          _nationalId!,
        ),
        builder: (context, snapshot) {
          // Debug info
          if (snapshot.hasError) {
            debugPrint('History Screen Error: ${snapshot.error}');
          }
          if (snapshot.hasData) {
            debugPrint(
              'History Screen: Loaded ${snapshot.data!.length} reports',
            );
          }

          final isLoading = snapshot.connectionState == ConnectionState.waiting;
          final reports = snapshot.data ?? [];

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 140,
                pinned: true,
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
                            Text(
                              l10n.myReports,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${reports.length} ${l10n.total.toLowerCase()}',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (isLoading)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: AppTheme.primary),
                  ),
                )
              else if (reports.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.receipt_long_outlined,
                            size: 48,
                            color: AppTheme.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.noReportsYet,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          l10n.startReporting,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.all(20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _ReportCard(
                          report: reports[i],
                          statusColor: _statusColor,
                          statusIcon: _statusIcon,
                          formatStatus: (s) => _formatStatus(s, context),
                        ),
                      ),
                      childCount: reports.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final Report report;
  final Color Function(String) statusColor;
  final IconData Function(String) statusIcon;
  final String Function(String) formatStatus;

  const _ReportCard({
    required this.report,
    required this.statusColor,
    required this.statusIcon,
    required this.formatStatus,
  });

  @override
  Widget build(BuildContext context) {
    final color = statusColor(report.status);
    final date = DateTime.parse(report.createdAt);
    final formatted = DateFormat('MMM dd, yyyy • hh:mm a').format(date);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image display using new ReportImageWidget
          if (report.hasImage())
            ReportImageFull(
              imagePath: report.imagePath,
              height: 140,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        report.type,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            statusIcon(report.status),
                            size: 12,
                            color: color,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            formatStatus(report.status),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  report.description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time_rounded,
                      size: 13,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      formatted,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                if (report.locationAddress != null ||
                    report.latitude != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        size: 13,
                        color: AppTheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          report.locationAddress ??
                              '${report.latitude!.toStringAsFixed(4)}, ${report.longitude!.toStringAsFixed(4)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.primary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
