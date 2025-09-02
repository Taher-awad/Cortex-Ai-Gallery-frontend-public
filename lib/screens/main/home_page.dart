import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cortex_ai_gallery/providers/settings_provider.dart';
import 'package:cortex_ai_gallery/services/upload_service.dart';
import 'package:cortex_ai_gallery/screens/main/all_media_page.dart';
import 'package:cortex_ai_gallery/screens/main/people_page.dart';
import 'package:cortex_ai_gallery/screens/main/settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final List<Widget> _pages = [const AllMediaPage(), const PeoplePage(), const SettingsPage()];

  late final void Function() _settingsListener;

  @override
  void initState() {
    super.initState();

    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);

    _settingsListener = () {
      _initOrUpdateUploadService(settingsProvider);
    };

    settingsProvider.addListener(_settingsListener);

    _initOrUpdateUploadService(settingsProvider);
  }

  void _initOrUpdateUploadService(SettingsProvider settings) {
    final uploadService = Provider.of<UploadService>(context, listen: false);

    if (settings.isAutoUploadEnabled && settings.watchedFolderPath != null) {
      uploadService.startWatching(settings.watchedFolderPath!);
    } else {
      uploadService.stopWatching();
    }
  }

  @override
  void dispose() {
    Provider.of<SettingsProvider>(context, listen: false).removeListener(_settingsListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
          index: _currentIndex,
          children: _pages
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        // CORRECTED: Using standard icons to prevent rendering issues
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.photo_library_outlined),
              activeIcon: Icon(Icons.photo_library),
              label: 'Media'
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.people_outline),
              activeIcon: Icon(Icons.add),
              label: 'People'
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'Settings'
          ),
        ],
      ),
    );
  }
}