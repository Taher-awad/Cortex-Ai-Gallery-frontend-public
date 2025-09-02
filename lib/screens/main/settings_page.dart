import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cortex_ai_gallery/providers/media_provider.dart';
import 'package:cortex_ai_gallery/providers/people_provider.dart';
import 'package:cortex_ai_gallery/providers/settings_provider.dart';
import 'package:cortex_ai_gallery/services/api_service.dart';
import 'package:cortex_ai_gallery/services/auth_service.dart';

// Top-level function for isolate computation
Future<String> _calculateFileHash(String path) async {
  final file = File(path);
  final stream = file.openRead();
  final hash = await sha256.bind(stream).first;
  return hash.toString();
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isUploading = false;
  String _uploadStatus = '';

  Future<void> _pickAndUploadFiles() async {
    setState(() {
      _isUploading = true;
      _uploadStatus = 'Selecting files...';
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.media,
      );

      if (result != null && result.files.isNotEmpty) {
        final apiService = context.read<ApiService>();
        final paths = result.paths.where((p) => p != null).cast<String>().toList();

        setState(() => _uploadStatus = 'Calculating file hashes...');
        final hashes = await Future.wait(paths.map((path) => compute(_calculateFileHash, path)));

        final fileHashMap = {for (var i = 0; i < hashes.length; i++) hashes[i]: File(paths[i])};

        setState(() => _uploadStatus = 'Checking for existing files...');
        final neededHashes = await apiService.checkHashes(hashes);
        final neededFiles = neededHashes.map((hash) => fileHashMap[hash]!).toList();

        if (neededFiles.isNotEmpty) {
          setState(() => _uploadStatus = 'Uploading ${neededFiles.length} new file(s)...');
          final success = await apiService.uploadFiles(neededFiles);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(success ? '${neededFiles.length} new file(s) uploaded successfully!' : 'Upload failed.')),
            );
            if (success) {
              context.read<MediaProvider>().refresh();
              context.read<PeopleProvider>().refresh();
            }
          }
        } else {
           if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('All selected files already exist on the server.')),
            );
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e')),
        );
      }
    } finally {
      if (context.mounted) {
        setState(() {
          _isUploading = false;
          _uploadStatus = '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final settings = Provider.of<SettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.upload_file_outlined),
            title: const Text('Manual Upload'),
            subtitle: const Text('Select photos and videos to upload'),
            onTap: _isUploading ? null : _pickAndUploadFiles,
            trailing: _isUploading
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 3)),
                        const SizedBox(height: 4),
                        Text(_uploadStatus, style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  )
                : null,
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Dark Mode'),
            secondary: const Icon(Icons.dark_mode_outlined),
            value: settings.isDarkMode,
            onChanged: (value) =>
                context.read<SettingsProvider>().toggleTheme(),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.folder_open_outlined),
            title: const Text('Auto-upload folder'),
            subtitle: Text(settings.watchedFolderPath ?? 'Not selected'),
            onTap: () async {
              String? selectedDirectory =
                  await FilePicker.platform.getDirectoryPath();
              if (selectedDirectory != null && context.mounted) {
                context
                    .read<SettingsProvider>()
                    .setWatchedFolder(selectedDirectory);
              }
            },
          ),
          SwitchListTile(
            title: const Text('Enable auto-upload'),
            secondary: const Icon(Icons.cloud_upload_outlined),
            value: settings.isAutoUploadEnabled,
            onChanged: settings.watchedFolderPath == null
                ? null
                : (value) {
                    context.read<SettingsProvider>().setAutoUpload(value);
                  },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.grid_on_outlined),
            title: const Text('Media grid columns'),
            trailing: DropdownButton<int>(
              value: settings.gridSize,
              items: [2, 3, 4, 5]
                  .map((size) =>
                      DropdownMenuItem(value: size, child: Text('$size')))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  context.read<SettingsProvider>().setGridSize(value);
                }
              },
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text('Logout'),
            onTap: () async => await authService.signOut(),
          ),
        ],
      ),
    );
  }
}