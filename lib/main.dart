import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:rum_tap/provider/audio_provider.dart';
import 'package:rum_tap/provider/panel_provider.dart';
import 'package:rum_tap/widgets/pads/drum_pad_panel.dart';
import 'package:rum_tap/widgets/mixer/mixer_panel.dart';
import 'package:rum_tap/widgets/pads/music_pad_panel.dart';
import 'package:rum_tap/widgets/panel/mixer_and_fade_panel.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

/////
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
      await audio.preloadMusics();

      setState(() {
        _ready = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return const MyApp();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('en'), // English
        Locale('es'), // Spanish
      ],
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.white)),
      home: const MyHomePage(title: 'Rum pad'),
    );
  }
}

class MyHomePage extends ConsumerWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String currentKit = "HIPHOP";

    final panel = ref.watch(panelControllerProvider);
    final controller = ref.watch(panelControllerProvider.notifier);
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 48,
        elevation: 0,
        backgroundColor: Colors.transparent,

        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(color: Colors.grey[900]!, width: 1),
          ),

          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  /// 🎧 TITLE (ชิดซ้าย)
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 26,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),

                  const Spacer(),

                  /// 🔒 LOCK (ชิดขวา)
                  IconButton(
                    onPressed: () {
                      controller.toggleIsLocked();
                    },
                    icon: Icon(
                      panel.isLocked ? Icons.lock : Icons.lock_open,
                      color: panel.isLocked ? Colors.redAccent : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Center(
        child: Row(
          children: [
            // --- พื้นที่ส่วนที่ 1 (20%) ---
            Expanded(flex: 20, child: MixerAndFadePanel()),
            // --- พื้นที่ส่วนที่ 2 (40%) ---
            const Expanded(
              flex: 30, // กำหนดสัดส่วน 40%
              child: MusicPadPanel(),
            ),
            // --- พื้นที่ส่วนที่ 3 (40%) ---
            const Expanded(flex: 50, child: DrumPadPanel()),
          ],
        ),
      ),
    );
  }
}
