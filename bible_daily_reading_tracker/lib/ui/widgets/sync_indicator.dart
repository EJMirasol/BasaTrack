import 'package:flutter/material.dart';
import '../../providers/sync_provider.dart';
import '../../core/theme/app_colors.dart';

/// Widget displaying sync status
class SyncIndicator extends StatelessWidget {
  final SyncProvider syncProvider;

  const SyncIndicator({
    super.key,
    required this.syncProvider,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Show only icon for syncing and offline (longest words)
    final bool isOnlyIcon = syncProvider.syncStatus == SyncStatus.syncing ||
                            syncProvider.syncStatus == SyncStatus.offline;

    return GestureDetector(
      onTap: () {
        if (syncProvider.syncStatus == SyncStatus.error) {
          syncProvider.syncAll();
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isOnlyIcon ? 4 : 3,
          vertical: 2,
        ),
        decoration: BoxDecoration(
          color: _getBackgroundColor().withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _getBackgroundColor().withOpacity(0.3),
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildIcon(),
            if (!isOnlyIcon) ...[
              const SizedBox(width: 2),
              Flexible(
                child: Text(
                  _getStatusText(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: _getBackgroundColor(),
                    fontWeight: FontWeight.w600,
                    fontSize: 9,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    switch (syncProvider.syncStatus) {
      case SyncStatus.syncing:
        return SizedBox(
          width: 10,
          height: 10,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            valueColor: AlwaysStoppedAnimation<Color>(_getBackgroundColor()),
          ),
        );
      case SyncStatus.synced:
        return Icon(
          Icons.cloud_done,
          size: 12,
          color: _getBackgroundColor(),
        );
      case SyncStatus.error:
        return Icon(
          Icons.error_outline,
          size: 12,
          color: _getBackgroundColor(),
        );
      case SyncStatus.offline:
        return Icon(
          Icons.cloud_off,
          size: 12,
          color: _getBackgroundColor(),
        );
      default:
        return Icon(
          Icons.cloud_queue,
          size: 12,
          color: _getBackgroundColor(),
        );
    }
  }

  String _getStatusText() {
    if (!syncProvider.isOnline) {
      return 'Offline';
    }

    switch (syncProvider.syncStatus) {
      case SyncStatus.syncing:
        return 'Syncing...';
      case SyncStatus.synced:
        return 'Synced';
      case SyncStatus.error:
        return 'Retry';
      case SyncStatus.offline:
        return 'Offline';
      default:
        return 'Sync';
    }
  }

  Color _getBackgroundColor() {
    if (!syncProvider.isOnline) {
      return Colors.grey;
    }

    switch (syncProvider.syncStatus) {
      case SyncStatus.syncing:
        return AppColors.primary;
      case SyncStatus.synced:
        return AppColors.success;
      case SyncStatus.error:
        return AppColors.error;
      case SyncStatus.offline:
        return Colors.grey;
      default:
        return AppColors.primary;
    }
  }
}
