import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cortex_ai_gallery/providers/media_provider.dart';
import 'package:cortex_ai_gallery/providers/people_provider.dart';
import 'package:cortex_ai_gallery/providers/person_media_provider.dart';
import 'package:cortex_ai_gallery/providers/settings_provider.dart';
import 'package:cortex_ai_gallery/screens/auth/auth_wrapper.dart';
import 'package:cortex_ai_gallery/services/api_service.dart';
import 'package:cortex_ai_gallery/services/auth_service.dart';
// Removed Isar and CacheManager imports
import 'package:cortex_ai_gallery/services/upload_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Foundational Services
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<ApiService>(create: (_) => ApiService()),
        // Removed IsarService provider

        // Dependent Services
        // Removed CacheManager provider
        ProxyProvider<ApiService, UploadService>(
          update: (_, apiService, __) => UploadService(apiService),
        ),

        // UI State Providers (ChangeNotifiers)
        ChangeNotifierProvider<SettingsProvider>(create: (_) => SettingsProvider()),
        ChangeNotifierProxyProvider<ApiService, MediaProvider>(
          create: (context) => MediaProvider(context.read<ApiService>()),
          update: (_, apiService, __) => MediaProvider(apiService),
        ),
        ChangeNotifierProxyProvider<ApiService, PeopleProvider>(
          create: (context) => PeopleProvider(context.read<ApiService>()),
          update: (_, apiService, __) => PeopleProvider(apiService),
        ),
        ChangeNotifierProxyProvider<ApiService, PersonMediaProvider>(
          create: (context) => PersonMediaProvider(context.read<ApiService>()),
          update: (_, apiService, __) => PersonMediaProvider(apiService),
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return MaterialApp(
            title: 'Cortex-AI Gallery',
            theme: ThemeData.light(useMaterial3: true),
            darkTheme: ThemeData.dark(useMaterial3: true),
            themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const AuthWrapper(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}