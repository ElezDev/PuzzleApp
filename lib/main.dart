import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'core/app_theme.dart';
import 'l10n/app_strings.dart';
import 'providers/app_provider.dart';
import 'screens/main_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
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
    final background = provider.globalBackground;
    final colors = provider.isDarkMode
        ? background.darkColors
        : background.lightColors;

    return MaterialApp(
      onGenerateTitle: (context) => AppStrings.of(context).appTitle,
      scaffoldMessengerKey: AppProvider.messengerKey,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: provider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      locale: provider.locale,
      supportedLocales: AppStrings.supportedLocales,
      localizationsDelegates: AppStrings.localizationsDelegates,
      builder: (context, child) => AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
        ),
        child: child,
      ),
      home: const MainShell(),
    );
  }
}
