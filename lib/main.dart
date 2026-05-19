import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:rum_tap/core/audio/audio_manager.dart';
import 'package:rum_tap/features/drum_pad/drum_pad_page.dart';
import 'package:rum_tap/features/drum_pad/models/pad_kits.dart';
import 'package:rum_tap/features/home/ui/audio_settings_widget.dart';
import 'l10n/app_localizations.dart';
import 'package:flutter/services.dart';

void main() async {
  // 2. ต้องใส่บรรทัดนี้ เพื่อให้แน่ใจว่า Flutter Engine พร้อมทำงานก่อนสั่งล็อกหน้าจอ
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  await AudioManager().init();

  await AudioManager().preloadPads(
    PadKits.kits.values.expand((e) => e).toList(),
  );

  runApp(const MyApp());
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
            Expanded(
              flex: 20,
              child: Container(
                color: Colors.red[200],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    /// 🎵 MUSIC
                    buildMixerSlider(
                      context,
                      title: "Music",
                      value: musicVolume,
                      onChanged: (v) {
                        setState(() {
                          sfxVolume = v;
                        });

                        AudioManager().setMusicVolume(
                          v,
                        ); // ⭐ คุมเสียง pad ทั้งหมด
                      },
                    ),

                    /// 🔊 SFX
                    buildMixerSlider(
                      context,
                      title: "SFX",
                      value: sfxVolume,
                      onChanged: (v) {
                        setState(() {
                          sfxVolume = v;
                        });

                        AudioManager().setSfxVolume(
                          v,
                        ); // ⭐ คุมเสียง pad ทั้งหมด
                      },
                    ),
                  ],
                ),
              ),
            ),

            // --- พื้นที่ส่วนที่ 2 (40%) ---
            Expanded(
              flex: 30, // กำหนดสัดส่วน 40%
              child: Container(
                color: Colors.blue[200],
                child: const Center(child: Text('40%')),
              ),
            ),
            // --- พื้นที่ส่วนที่ 3 (40%) ---
            const Expanded(flex: 50, child: DrumPadPage()),
          ],
        ),
      ),
    );
  }
}
