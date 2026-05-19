import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:rum_tap/provider/audio_provider.dart';
import 'package:rum_tap/widgets/pads/drum_pad_panel.dart';
import 'package:rum_tap/widgets/mixer/mixer_panel.dart';
import 'package:rum_tap/widgets/pads/music_pad_panel.dart';
import 'package:rum_tap/widgets/panel/mixer_and_fade_panel.dart';
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
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String currentKit = "HIPHOP";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
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
