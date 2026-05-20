import 'package:flutter/material.dart';

class AppInfoPage extends StatelessWidget {
  const AppInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("About App", style: TextStyle(color: Colors.white)),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🎧 LEFT SIDE (App info)
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Rum Pad",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  SizedBox(height: 8),

                  Text(
                    "Drum Pad / Mixer Music App",
                    style: TextStyle(color: Colors.white70),
                  ),

                  SizedBox(height: 20),

                  Text("Version: 1.0.0", style: TextStyle(color: Colors.white)),

                  SizedBox(height: 8),

                  Text(
                    "Developer: Patipan Areyukong",
                    style: TextStyle(color: Colors.white),
                  ),

                  SizedBox(height: 8),

                  Text(
                    "Email: patipan.dev@gmail.com",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 20),

            /// ⚙️ RIGHT SIDE (Features)
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Features",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),

                  SizedBox(height: 12),

                  Text(
                    "• Drum Pad Play",
                    style: TextStyle(color: Colors.white70),
                  ),
                  Text(
                    "• Music Mixer",
                    style: TextStyle(color: Colors.white70),
                  ),
                  Text(
                    "• Waveform Visualization",
                    style: TextStyle(color: Colors.white70),
                  ),
                  Text(
                    "• Multi Language Support",
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
