import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:cortex_ai_gallery/providers/person_media_provider.dart';
import 'package:cortex_ai_gallery/providers/settings_provider.dart';
import 'package:cortex_ai_gallery/screens/main/media_viewer_page.dart';
import 'package:cortex_ai_gallery/widgets/cached_image_widget.dart';

class PersonMediaPage extends StatefulWidget {
  final String personId;
  final String personName;

  const PersonMediaPage({
    super.key,
    required this.personId,
    required this.personName,
  });

  @override
  State<PersonMediaPage> createState() => _PersonMediaPageState();
}

class _PersonMediaPageState extends State<PersonMediaPage> {
  @override
  void initState() {
    super.initState();
    // Fetch media for the person when the page is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PersonMediaProvider>(context, listen: false)
          .fetchMedia(widget.personId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.personName),
      ),
      body: Consumer<PersonMediaProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.mediaItems.isEmpty) {
            return const Center(child: Text('No media found for this person.'));
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchMedia(widget.personId),
            child: MasonryGridView.builder(
              padding: const EdgeInsets.all(4.0),
              itemCount: provider.mediaItems.length,
              gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: settings.gridSize),
              itemBuilder: (context, index) {
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
