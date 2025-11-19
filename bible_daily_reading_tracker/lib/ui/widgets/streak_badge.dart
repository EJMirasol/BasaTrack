import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';

/// Badge widget for displaying streak information
class StreakBadge extends StatefulWidget {
  final int currentStreak;
  final int longestStreak;
  final bool isWeekStreak;

  const StreakBadge({
    super.key,
    required this.currentStreak,
    required this.longestStreak,
    this.isWeekStreak = false,
  });

  @override
  State<StreakBadge> createState() => _StreakBadgeState();
}

class _StreakBadgeState extends State<StreakBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.isWeekStreak) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(StreakBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isWeekStreak && !oldWidget.isWeekStreak) {
      _controller.repeat(reverse: true);
    } else if (!widget.isWeekStreak && oldWidget.isWeekStreak) {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getStreakColor() {
    if (widget.currentStreak == 0) return AppColors.textSecondary;
    if (widget.currentStreak < 7) return AppColors.primary;
    if (widget.currentStreak < 30) return AppColors.secondary;
    return AppColors.streakGold;
  }

  IconData _getStreakIcon() {
    if (widget.currentStreak == 0) return Icons.book_outlined;
    if (widget.currentStreak < 7) return Icons.local_fire_department;
    if (widget.currentStreak < 30) return Icons.star;
    if (widget.currentStreak < 100) return Icons.emoji_events;
    return Icons.workspace_premium;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final streakColor = _getStreakColor();

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.isWeekStreak ? _pulseAnimation.value : 1.0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: widget.isWeekStreak
                  ? LinearGradient(
                      colors: [
                        AppColors.secondary,
                        AppColors.secondaryLight,
                      ],
                    )
                  : null,
              color: widget.isWeekStreak
                  ? null
                  : streakColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: streakColor.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getStreakIcon(),
                  color: widget.isWeekStreak ? Colors.white : streakColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${widget.currentStreak} Day${widget.currentStreak == 1 ? '' : 's'}',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: widget.isWeekStreak ? Colors.white : streakColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (widget.longestStreak > widget.currentStreak)
                      Text(
                        'Best: ${widget.longestStreak}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: widget.isWeekStreak
                              ? Colors.white.withOpacity(0.9)
                              : AppColors.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
