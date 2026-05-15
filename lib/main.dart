import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'theme.dart';
import 'screens/login_screen.dart';
import 'screens/user/problem_report_screen.dart';
import 'providers/language_provider.dart';
import 'providers/cart_provider.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyCj0n9DahAZ3i-2H3iimjBn-nnm0XPP2bw',
      authDomain: 'salamtak-app-f26c4.firebaseapp.com',
      projectId: 'salamtak-app-f26c4',
      storageBucket: 'salamtak-app-f26c4.firebasestorage.app',
      messagingSenderId: '390524157451',
      appId: '1:390524157451:web:43fa54f7c60233f503910e',
    ),
  );

  print('');
  print('╔════════════════════════════════════════╗');
  print('║         LOGIN CREDENTIALS             ║');
  print('╠════════════════════════════════════════╣');
  print('║ ADMIN:                                 ║');
  print('║   Work ID: 221007689                   ║');
  print('║   Password: 631663                     ║');
  print('║                                        ║');
  print('║ TEST USER:                             ║');
  print('║   National ID: 11111111111111          ║');
  print('║   Password: user123456                 ║');
  print('╚════════════════════════════════════════╝');
  print('');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: const SalamtakApp(),
    ),
  );
}

class SalamtakApp extends StatelessWidget {
  const SalamtakApp({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return MaterialApp(
      title: 'Salamtak',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      locale: languageProvider.locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      // Set text direction based on language
      builder: (context, child) {
        return Directionality(
          textDirection:
              languageProvider.isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: child!,
        );
      },
      routes: {
        '/report-problem': (context) {
          final problemType =
              ModalRoute.of(context)!.settings.arguments as String;
          return ProblemReportScreen(problemType: problemType);
        },
      },
      home: const LoginScreen(),
    );
  }
}
