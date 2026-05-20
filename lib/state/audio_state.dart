class AudioState {
  final double musicVolume;
  final double sfxVolume;
  final bool musicMuted;
  final bool sfxMuted;

  final Map<String, bool> padPlaying;

  final int fadeInDurationMs; // 👈 เพิ่มตัวนี้เข้าไป (หน่วยมิลลิวินาที)
  final int fadeOutDurationMs; // 👈 เพิ่มตัวนี้เข้าไปด้วยสำหรับฝั่ง Fade Out
  final bool isFading;

  final String? currentMusicAsset;

  const AudioState({
    required this.musicVolume,
    required this.sfxVolume,
    required this.musicMuted,
    required this.sfxMuted,
    required this.padPlaying,
    this.fadeInDurationMs = 1500, // ตั้งค่าเริ่มต้นไว้ที่ 1.5 วินาที
    this.fadeOutDurationMs = 1500, // ตั้งค่าเริ่มต้นไว้ที่ 1.5 วินาที
    this.isFading = false,

    this.currentMusicAsset,
  });

  AudioState copyWith({
    double? musicVolume,
    double? sfxVolume,
    bool? musicMuted,
    bool? sfxMuted,
    Map<String, bool>? padPlaying,
    int? fadeInDurationMs,
    int? fadeOutDurationMs,
    bool? isFading,
    String? currentMusicAsset,
  }) {
    return AudioState(
      musicVolume: musicVolume ?? this.musicVolume,
      sfxVolume: sfxVolume ?? this.sfxVolume,
      musicMuted: musicMuted ?? this.musicMuted,
      sfxMuted: sfxMuted ?? this.sfxMuted,

      /// ⭐ สำคัญ
      padPlaying: padPlaying ?? this.padPlaying,
      fadeInDurationMs: fadeInDurationMs ?? this.fadeInDurationMs,
      fadeOutDurationMs: fadeOutDurationMs ?? this.fadeOutDurationMs,
      isFading: isFading ?? this.isFading,
      currentMusicAsset: currentMusicAsset ?? this.currentMusicAsset,
    );
  }
}
