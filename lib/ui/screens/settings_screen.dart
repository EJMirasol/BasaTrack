import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import '../../providers/auth_provider.dart';
import '../../providers/reading_provider.dart';
import '../../providers/streak_provider.dart';
import '../../data/repositories/storage_service.dart';
import '../../core/theme/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Settings & Data'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          _buildSectionHeader(context, 'Data Management'),
          ListTile(
            leading: const Icon(Icons.upload_file, color: AppColors.primary),
            title: const Text('Export Progress'),
            subtitle: const Text('Save your data as a JSON file'),
            onTap: () => _handleExport(context),
          ),
          ListTile(
            leading: const Icon(Icons.download, color: AppColors.primary),
            title: const Text('Import Progress'),
            subtitle: const Text('Restore data from a JSON file'),
            onTap: () => _handleImport(context),
          ),
          const Divider(),
          _buildSectionHeader(context, 'Account'),
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: AppColors.error),
            title: const Text('Exit Session'),
            subtitle: const Text('Sign out of the current local session'),
            onTap: () => _handleExit(context, authProvider),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Your data is stored locally on this device. Use Export to back up your progress.',
              style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
      ),
    );
  }

  Future<void> _handleExport(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final storage = StorageService();
    
    try {
      final data = await storage.exportData();
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${tempDir.path}/basatrack_backup_$timestamp.json');
      await file.writeAsString(data);
      
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'BasaTrack Data Backup',
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Failed to export: $e')),
      );
    }
  }

  Future<void> _handleImport(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      
      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final content = await file.readAsString();
        
        final storage = StorageService();
        await storage.importData(content);
        
        messenger.showSnackBar(
          const SnackBar(content: Text('Progress imported successfully!')),
        );
        
        // Reload data after import
        if (context.mounted) {
          context.read<ReadingProvider>().loadTodaySchedule();
          context.read<StreakProvider>().loadProgress();
        }
      }
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Failed to import: $e')),
      );
    }
  }

  Future<void> _handleExit(BuildContext context, AuthProvider authProvider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Session?'),
        content: const Text('This will return you to the start screen. Your data will remain on this device.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Exit'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await authProvider.signOut();
    }
  }
}
