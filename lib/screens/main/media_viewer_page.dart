import 'dart:async';
import 'package:cortex_ai_gallery/models/media_item.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';
import 'package:video_player/video_player.dart';

class MediaViewerPage extends StatefulWidget {
  final List<MediaItem> mediaItems;
  final int initialIndex;

  const MediaViewerPage({
    super.key,
    required this.mediaItems,
    required this.initialIndex,
  });

  @override
  State<MediaViewerPage> createState() => _MediaViewerPageState();
}

class _MediaViewerPageState extends State<MediaViewerPage> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _downloadCurrentMedia() async {
    if (await Permission.photos.request().isGranted) {
      final int currentPage = _pageController.page?.round() ?? widget.initialIndex;
      final MediaItem currentItem = widget.mediaItems[currentPage];

      try {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Downloading...')),
        );

        bool? success;
        if (currentItem.fileType.toLowerCase() == 'video') {
          success = await GallerySaver.saveVideo(currentItem.mediaUrl);
        } else {
          success = await GallerySaver.saveImage(currentItem.mediaUrl);
        }

        if (context.mounted) {
          if (success == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Downloaded successfully!')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Download failed.')),
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Download failed: $e')),
          );
        }
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Storage permission denied.')),
        );
      }
    }
  }

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'download':
        _downloadCurrentMedia();
        break;
      case 'copy':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Copy feature not yet implemented.')),
        );
        break;
      case 'delete':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Delete feature not yet implemented.')),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          PopupMenuButton<String>(
            onSelected: _handleMenuSelection,
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'download',
                child: ListTile(
                  leading: Icon(Icons.download),
                  title: Text('Download'),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'copy',
                child: ListTile(
                  leading: Icon(Icons.copy),
                  title: Text('Copy'),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'delete',
                child: ListTile(
                  leading: Icon(Icons.delete),
                  title: Text('Delete'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.mediaItems.length,
        itemBuilder: (context, index) {
          final item = widget.mediaItems[index];
          return _MediaContent(
            mediaUrl: item.mediaUrl,
            fileType: item.fileType,
            heroTag: item.id,
          );
        },
      ),
    );
  }
}

class _MediaContent extends StatefulWidget {
  final String mediaUrl;
  final String fileType;
  final Object heroTag;

  const _MediaContent({
    required this.mediaUrl,
    required this.fileType,
    required this.heroTag,
  });

  @override
  __MediaContentState createState() => __MediaContentState();
}

class __MediaContentState extends State<_MediaContent>
    with AutomaticKeepAliveClientMixin {
  VideoPlayerController? _videoPlayerController;
  bool _isVideoInitialized = false;
  bool _showControls = true;
  Timer? _controlsTimer;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    if (widget.fileType.toLowerCase() == 'video') {
      _videoPlayerController =
          VideoPlayerController.networkUrl(Uri.parse(widget.mediaUrl))
            ..initialize().then((_) {
              if (mounted) {
                setState(() => _isVideoInitialized = true);
                _videoPlayerController?.addListener(_videoListener);
                _videoPlayerController?.play();
                _videoPlayerController?.setLooping(true);
                _startControlsTimer();
              }
            });
    }
  }

  @override
  void dispose() {
    _videoPlayerController?.removeListener(_videoListener);
    _videoPlayerController?.dispose();
    _controlsTimer?.cancel();
    super.dispose();
  }

  void _videoListener() {
    if (!mounted) return;
    // The listener is used to rebuild the widget when the playing state changes.
    setState(() {});
  }

  void _startControlsTimer() {
    _controlsTimer?.cancel();
    _controlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _showControls = false);
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
      if (_showControls) {
        _startControlsTimer();
      } else {
        _controlsTimer?.cancel();
      }
    });
  }

  void _toggleVideoPlayback() {
    if (_videoPlayerController == null) return;
    final isPlaying = _videoPlayerController!.value.isPlaying;
    isPlaying ? _videoPlayerController!.pause() : _videoPlayerController!.play();
    // The listener will call setState.
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Important for AutomaticKeepAliveClientMixin
    return Center(
      child: Hero(
        tag: widget.heroTag,
        child: widget.fileType.toLowerCase() == 'image'
            ? PhotoView(
                imageProvider: NetworkImage(widget.mediaUrl),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 2,
              )
            : _isVideoInitialized && _videoPlayerController != null
                ? GestureDetector(
                    onTap: _toggleControls,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        AspectRatio(
                          aspectRatio: _videoPlayerController!.value.aspectRatio,
                          child: VideoPlayer(_videoPlayerController!),
                        ),
                        AnimatedOpacity(
                          opacity: _showControls ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 300),
                          child: Container(
                            color: Colors.black.withOpacity(0.4),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    _videoPlayerController!.value.isPlaying
                                        ? Icons.pause_circle_filled
                                        : Icons.play_circle_filled,
                                    color: Colors.white,
                                    size: 64.0,
                                  ),
                                  onPressed: _toggleVideoPlayback,
                                ),
                                VideoProgressIndicator(
                                  _videoPlayerController!,
                                  allowScrubbing: true,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10.0, horizontal: 16.0),
                                  colors: const VideoProgressColors(
                                    playedColor: Colors.red,
                                    bufferedColor: Colors.white54,
                                    backgroundColor: Colors.white24,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : const CircularProgressIndicator(),
      ),
    );
  }
}
