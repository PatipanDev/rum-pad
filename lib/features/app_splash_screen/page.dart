import 'package:flutter/material.dart';

/// หน้าจอ Splash Screen แสดงโลโก้ของแอปแบบพรีเมียมระหว่างโหลดทรัพยากรเสียงหลังบ้าน
class AppSplashScreen extends StatelessWidget {
  const AppSplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          // ใช้ Gradient ไล่เฉดสีเพื่อเพิ่มมิติความสวยงามให้พื้นหลัง (สามารถปรับให้เข้ากับโทนสีแอปของคุณได้เลย)
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                // Color(0xFF1E293B), // สีน้ำเงินเข้มสว่าง
                Color(0xFF0F172A), // สีน้ำเงินเกือบดำลึก
                Colors.black,
              ],
            ),
          ),
          child: SafeArea(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // ส่วนของ Content ตรงกลางหน้าจอ (โลโก้ + ชื่อแอป)
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ส่วนแสดงโลโก้แอปพลิเคชัน
                    Container(
                      width: 140,
                      height: 140,
                      // decoration: BoxDecoration(
                      //   color: Colors.white.withValues(alpha: 0.08),
                      //   borderRadius: BorderRadius.circular(32),
                      //   boxShadow: [
                      //     BoxShadow(
                      //       color: Colors.black,
                      //       blurRadius: 24,
                      //       offset: const Offset(0, 12),
                      //     ),
                      //   ],
                      // ),
                      padding: const EdgeInsets.all(20),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          'assets/images/app_icon_foreground.png',
                          // 👈 ใส่ที่อยู่รูปโลโก้แอปของคุณที่นี่
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            // กรณีที่ยังไม่ได้เซ็ตอัพรูปภาพ หรือหาไฟล์ไม่เจอ จะแสดง Icon ดนตรีเริ่มต้นทดแทน เพื่อไม่ให้แอปแครช
                            return const Icon(
                              Icons
                                  .music_note_rounded, // 👈 เปลี่ยนเป็นไอคอนอื่นตามธีมแอปได้ครับ
                              size: 72,
                              color: Colors.white,
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // ชื่อแอปของคุณ
                    const Text(
                      'Rum Pad', // 👈 เปลี่ยนเป็นชื่อแอปของคุณได้ที่นี่
                      style: TextStyle(
                        fontFamily:
                            'NotoSansThai', // สามารถใส่ฟอนต์ภาษาไทยของแอปคุณได้
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // คำโปรยหรือคำบรรยายสั้น ๆ (Tagline)
                    Text(
                      'Music is life', // 👈 ใส่คำบรรยายหรือสโลแกนสั้น ๆ
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withValues(alpha: 0.5),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                // สัญลักษณ์การโหลดเล็ก ๆ ด้านล่างสุด เพื่อบ่งบอกให้ผู้ใช้รู้ว่ากำลังเตรียมข้อมูลระบบอยู่
                Positioned(
                  bottom: 20,
                  child: Column(
                    children: [
                      SizedBox(
                        width: 120,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: const LinearProgressIndicator(
                            minHeight: 4,
                            backgroundColor: Colors.white10,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white60,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Loading...',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
