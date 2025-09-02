import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cortex_ai_gallery/providers/people_provider.dart';
import 'package:cortex_ai_gallery/providers/settings_provider.dart';
import 'package:cortex_ai_gallery/screens/main/person_media_page.dart';
import 'package:cortex_ai_gallery/widgets/cached_image_widget.dart';

class PeoplePage extends StatelessWidget {
  const PeoplePage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    //final peopleProvider = Provider.of<PeopleProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('People')),
      // The Consumer widget will now correctly rebuild when data arrives
      body: Consumer<PeopleProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Wrap the grid in a RefreshIndicator
          return RefreshIndicator(
            onRefresh: () => provider.refresh(),
            child: provider.people.isEmpty
                ? const Center(child: Text('No people found yet.')) // Show message if list is empty
                : GridView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: provider.people.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: settings.gridSize > 2 ? settings.gridSize - 1 : 2,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemBuilder: (context, index) {
                final person = provider.people[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PersonMediaPage(
                          personId: person.personId,
                          personName: person.name,
                        ),
                      ),
                    );
                  },
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    child: GridTile(
                      footer: GridTileBar(
                        backgroundColor: Colors.black45,
                        title: Text(person.name),
                        subtitle: Text('${person.faceCount} photos'),
                      ),
                      child:
                          CachedImageWidget(imageUrl: person.coverThumbnailUrl),
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