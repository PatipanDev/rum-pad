import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:rum_tap/features/Info/page.dart';
import 'package:rum_tap/features/app_splash_screen/page.dart';
import 'package:rum_tap/provider/audio_provider.dart';
import 'package:rum_tap/provider/locale_provider.dart';
import 'package:rum_tap/provider/panel_provider.dart';
import 'package:rum_tap/widgets/pads/drum_pad_panel.dart';
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

class MyHomePage extends ConsumerWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;

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
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: [
                  /// Lodo (ชิดซ้าย)
                  Container(
                    padding: const EdgeInsets.all(4),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(0),
                      child: Image.asset(
                        'assets/images/app_icon_foreground.png',
                        // 👈 ใส่ที่อยู่รูปโลโก้แอปของคุณที่นี่
                        width: 32,
                        height: 32,
                        // fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          // กรณีที่ยังไม่ได้เซ็ตอัพรูปภาพ หรือหาไฟล์ไม่เจอ จะแสดง Icon ดนตรีเริ่มต้นทดแทน เพื่อไม่ให้แอปแครช
                          return const Icon(
                            Icons
                                .music_note_rounded, // 👈 เปลี่ยนเป็นไอคอนอื่นตามธีมแอปได้ครับ
                            size: 56,
                            color: Colors.white,
                          );
                        },
                      ),
                    ),
                  ),

                  ShaderMask(
                    shaderCallback: (bounds) {
                      return const LinearGradient(
                        colors: [
                          Color(0xFFFFD700), // gold สว่าง
                          Color(0xFFFFA000), // amber
                          Color(0xFF8B6508), // gold เข้ม
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds);
                    },
                    child: Text(
                      t.nameApp,
                      style: const TextStyle(
                        fontSize: 26,
                        color: Colors.white, // ต้องใส่ไว้ แต่จะถูก mask ทับ
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
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

                  DropdownButton<Locale>(
                    value: ref.watch(localeProvider),
                    dropdownColor: Colors.black,
                    style: const TextStyle(color: Colors.white),

                    items: const [
                      DropdownMenuItem(
                        value: Locale('en'),
                        child: Text("English"),
                      ),
                      DropdownMenuItem(value: Locale('th'), child: Text("ไทย")),
                      DropdownMenuItem(value: Locale('lo'), child: Text("ລາວ")),
                      DropdownMenuItem(
                        value: Locale('my'),
                        child: Text("မြန်မာ"),
                      ),
                      DropdownMenuItem(value: Locale('zh'), child: Text("中文")),
                      DropdownMenuItem(value: Locale('ko'), child: Text("한국어")),
                      DropdownMenuItem(value: Locale('ja'), child: Text("日本語")),
                      DropdownMenuItem(
                        value: Locale('ms'),
                        child: Text("Bahasa Melayu"),
                      ),
                      DropdownMenuItem(
                        value: Locale('pt'),
                        child: Text("Português"),
                      ),
                      DropdownMenuItem(
                        value: Locale('id'),
                        child: Text("Indonesia"),
                      ),
                    ],

                    onChanged: (value) {
                      if (value == null) return;
                      ref.read(localeProvider.notifier).state = value;
                    },
                  ),

                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  const AppInfoPage(),

                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                                const begin = Offset(1.0, 0.0); // มาจากขวา
                                const end = Offset.zero;
                                const curve = Curves.easeOutCubic;

                                final tween = Tween(
                                  begin: begin,
                                  end: end,
                                ).chain(CurveTween(curve: curve));

                                return SlideTransition(
                                  position: animation.drive(tween),
                                  child: child,
                                );
                              },
                        ),
                      );
                    },
                    icon: Icon(Icons.info),
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
