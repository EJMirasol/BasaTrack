import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/reading_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../data/data_sources/reading_plan_data.dart';
import 'pdf_viewer_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const int totalWeeks = 104;

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

  void _openPdfViewer(BuildContext context) {
    final isOT = _tabController.index == 0;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PdfViewerScreen(
          title: isOT
              ? 'Old Testament Schedule (PDF)'
              : 'New Testament Schedule (PDF)',
          assetPath: isOT
              ? 'assets/PDF/OTReadingSchedule.pdf'
              : 'assets/PDF/NTReadingSchedule.pdf',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final readingProvider = context.watch<ReadingProvider>();
    final completedIds = readingProvider.getCompletedTaskIds();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Reading History',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _openPdfViewer(context),
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Verify with PDF',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey.shade600,
          indicatorColor: AppColors.primary,
          indicatorSize: TabBarIndicatorSize.label,
          tabs: const [
            Tab(text: 'Old Testament'),
            Tab(text: 'New Testament'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildReadingList(completedIds, 'ot'),
          _buildReadingList(completedIds, 'nt'),
        ],
      ),
    );
  }

  Widget _buildReadingList(Set<String> completedIds, String type) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: totalWeeks,
      itemBuilder: (context, weekIndex) {
        final weekNumber = weekIndex + 1;
        final weekReadings = ReadingPlanData.getWeekReadings(weekNumber);
        if (weekReadings == null) return const SizedBox.shrink();

        final daysInWeek = weekReadings.length;
        var completedInWeek = 0;
        for (int d = 0; d < daysInWeek; d++) {
          final taskId = 'week_${weekNumber}_day_${d + 1}_$type';
          if (completedIds.contains(taskId)) completedInWeek++;
        }
        final allCompleted = completedInWeek == daysInWeek;

        return _WeekExpansionTile(
          weekNumber: weekNumber,
          daysInWeek: daysInWeek,
          completedCount: completedInWeek,
          allCompleted: allCompleted,
          type: type,
          completedIds: completedIds,
        );
      },
    );
  }
}

class _WeekExpansionTile extends StatefulWidget {
  final int weekNumber;
  final int daysInWeek;
  final int completedCount;
  final bool allCompleted;
  final String type;
  final Set<String> completedIds;

  const _WeekExpansionTile({
    required this.weekNumber,
    required this.daysInWeek,
    required this.completedCount,
    required this.allCompleted,
    required this.type,
    required this.completedIds,
  });

  @override
  State<_WeekExpansionTile> createState() => _WeekExpansionTileState();
}

class _WeekExpansionTileState extends State<_WeekExpansionTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final weekReadings = ReadingPlanData.getWeekReadings(widget.weekNumber);
    if (weekReadings == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: widget.allCompleted
              ? AppColors.success.withValues(alpha: 0.3)
              : Colors.grey.shade100,
        ),
      ),
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          childrenPadding:
              const EdgeInsets.only(left: 12, right: 12, bottom: 8),
          onExpansionChanged: (expanded) {
            setState(() => _isExpanded = expanded);
          },
          leading: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: widget.allCompleted
                  ? AppColors.success.withValues(alpha: 0.1)
                  : AppColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: widget.allCompleted
                  ? const Icon(Icons.check, size: 16, color: AppColors.success)
                  : Icon(
                      _isExpanded ? Icons.expand_less : Icons.expand_more,
                      size: 16,
                      color: AppColors.primary,
                    ),
            ),
          ),
          title: Row(
            children: [
              Text(
                'Week ${widget.weekNumber}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${widget.completedCount}/${widget.daysInWeek}',
                style: TextStyle(
                  fontSize: 12,
                  color: widget.allCompleted
                      ? AppColors.success
                      : Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          trailing: SizedBox(
            width: 60,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value:
                    (widget.completedCount / widget.daysInWeek).clamp(0.0, 1.0),
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation<Color>(
                  widget.allCompleted ? AppColors.success : AppColors.primary,
                ),
                minHeight: 6,
                semanticsLabel:
                    '${widget.completedCount} of ${widget.daysInWeek} completed',
              ),
            ),
          ),
          children: List.generate(weekReadings.length, (dayIndex) {
            final dayNumber = dayIndex + 1;
            final dayReadings = weekReadings[dayIndex];
            final reference =
                widget.type == 'ot' ? dayReadings['ot'] : dayReadings['nt'];
            final taskId =
                'week_${widget.weekNumber}_day_${dayNumber}_${widget.type}';
            final isCompleted = widget.completedIds.contains(taskId);

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  SizedBox(
                    width: 32,
                    child: isCompleted
                        ? const Icon(Icons.check_box,
                            size: 20, color: AppColors.success)
                        : Icon(Icons.check_box_outline_blank,
                            size: 20, color: Colors.grey.shade400),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 72,
                    child: Text(
                      ReadingPlanData.getDayName(dayNumber),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isCompleted
                            ? AppColors.textPrimary
                            : Colors.grey.shade500,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      (reference != null && reference.isNotEmpty)
                          ? reference
                          : '—',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isCompleted
                            ? AppColors.textPrimary
                            : Colors.grey.shade500,
                        decoration: isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
