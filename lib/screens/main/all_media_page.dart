import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:cortex_ai_gallery/providers/media_provider.dart';
import 'package:cortex_ai_gallery/providers/people_provider.dart';
import 'package:cortex_ai_gallery/providers/settings_provider.dart';
import 'package:cortex_ai_gallery/services/api_service.dart';
import 'package:cortex_ai_gallery/widgets/cached_image_widget.dart';

import 'media_viewer_page.dart';

class AllMediaPage extends StatefulWidget {
  const AllMediaPage({super.key});

  @override
  State<AllMediaPage> createState() => _AllMediaPageState();
}

class _AllMediaPageState extends State<AllMediaPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    final mediaProvider = Provider.of<MediaProvider>(context, listen: false);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 300) {
        mediaProvider.fetchMedia();
      }
    });
  }

  Future<String> _calculateHash(File file) async {
    final stream = file.openRead();
    final hash = await sha256.bind(stream).first;
    return hash.toString();
  }

  Future<void> _pickAndUploadFiles() async {
    setState(() => _isUploading = true);

    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.media,
    );

    if (result != null && result.files.isNotEmpty) {
      final apiService = context.read<ApiService>();
      final filesToUpload = result.paths.map((path) => File(path!)).toList();

      final hashes = await Future.wait(filesToUpload.map((file) => _calculateHash(file)));
      final fileHashMap = {for (var i = 0; i < hashes.length; i++) hashes[i]: filesToUpload[i]};

      final neededHashes = await apiService.checkHashes(hashes);
      final neededFiles = neededHashes.map((hash) => fileHashMap[hash]!).toList();

      if (neededFiles.isNotEmpty) {
        final success = await apiService.uploadFiles(neededFiles);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(success ? '${neededFiles.length} new file(s) uploaded successfully!' : 'Upload failed.')),
          );

          if (success) {
            await Future.delayed(const Duration(seconds: 2));
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

    if (context.mounted) {
      setState(() => _isUploading = false);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Media'),
        actions: [
          // CORRECTED: Replaced icon to ensure it renders correctly
          if (_isUploading)
            const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 3))),
            )
          else
            IconButton(
              icon: const Icon(Icons.upload_file), // Using a standard icon
              tooltip: 'Upload from Gallery',
              onPressed: _pickAndUploadFiles,
            ),
        ],
      ),
      body: Consumer<MediaProvider>(
        builder: (context, provider, child) {
          // ... rest of the file is the same
          if (provider.mediaItems.isEmpty && provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () => provider.refresh(),
            child: MasonryGridView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(4.0),
              itemCount: provider.mediaItems.length + (provider.hasMore ? 1 : 0),
              gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(crossAxisCount: settings.gridSize),
              itemBuilder: (context, index) {
                if (index == provider.mediaItems.length) {
                  return const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator()));
                }
                final item = provider.mediaItems[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MediaViewerPage(
                            mediaItems: provider.mediaItems,
                            initialIndex: index,
                          ),
                        ),
                      );
                    },
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    child: Hero(
                      tag: item.id,
                      child: CachedImageWidget(imageUrl: item.thumbnailUrl),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}