import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/app_theme.dart';
import 'providers/app_provider.dart';
import 'screens/main_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  final appProvider = AppProvider();
  await appProvider.initialize();

  runApp(
    ChangeNotifierProvider.value(
      value: appProvider,
      child: const PuzlessApp(),
    ),
  );
}

class PuzlessApp extends StatelessWidget {
  const PuzlessApp({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return MaterialApp(
      title: 'Puzless',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: provider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const MainShell(),
    );
  }
}
