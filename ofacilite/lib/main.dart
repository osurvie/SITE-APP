import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ofacilite/core/services/notification_service.dart';
import 'package:ofacilite/features/home/home_screen.dart';

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await NotificationService.instance.init();
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('fr'), Locale('en'), Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: const Locale('fr'),
      child: const OFaciliteApp(),
    ),
  );
}

class OFaciliteApp extends StatelessWidget {
  const OFaciliteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "O'Facilit",
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1565C0)),
        useMaterial3: true,
      ),
      navigatorObservers: [routeObserver],
      home: const HomeScreen(),
    );
  }
}
