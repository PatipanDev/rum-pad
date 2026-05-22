import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:rum_tap/features/app_splash_screen/page.dart';
import 'package:rum_tap/features/home/ui/page.dart';
import 'package:rum_tap/provider/audio_provider.dart';
import 'package:rum_tap/provider/locale_provider.dart';
import 'l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  // 2. ต้องใส่บรรทัดนี้ เพื่อให้แน่ใจว่า Flutter Engine พร้อมทำงานก่อนสั่งล็อกหน้าจอ
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(const ProviderScope(child: AppBootstrap()));
}

class AppBootstrap extends ConsumerStatefulWidget {
  const AppBootstrap({super.key});

  @override
  ConsumerState<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends ConsumerState<AppBootstrap> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final audio = ref.read(audioControllerProvider.notifier);

      await audio.init();
      await audio.preloadPads();
      // await audio.preloadMusics();

      setState(() {
        _ready = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const AppSplashScreen();
    }

    return const MyApp();
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    return MaterialApp(
      title: 'Rum pad',
      locale: locale,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        if (locale == null) return supportedLocales.first;

        for (var supported in supportedLocales) {
          if (supported.languageCode == locale.languageCode) {
            return supported;
          }
        }

        return supportedLocales.first;
      },
      supportedLocales: const [
        Locale('en'),
        Locale('th'),
        Locale('lo'), // ลาว
        Locale('my'), // พม่า
        Locale('zh'), // จีน
        Locale('ko'), // เกาหลี
        Locale('ja'), // ญี่ปุ่น
        Locale('ms'), // มาเลเซีย
        Locale('pt'), // โปรตุเกส
        Locale('id'), // อินโดนีเซีย
      ],
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.white)),
      home: const MyHomePage(),
    );
  }
}

