class AudioState {
  final double musicVolume;
  final double sfxVolume;
  final bool musicMuted;
  final bool sfxMuted;

   final Map<String, bool> padPlaying;

  const AudioState({
    required this.musicVolume,
    required this.sfxVolume,
    required this.musicMuted,
    required this.sfxMuted,
    required this.padPlaying,
  });

  AudioState copyWith({
    double? musicVolume,
    double? sfxVolume,
    bool? musicMuted,
    bool? sfxMuted,
    Map<String, bool>? padPlaying,
  }) {
    return AudioState(
      musicVolume: musicVolume ?? this.musicVolume,
      sfxVolume: sfxVolume ?? this.sfxVolume,
      musicMuted: musicMuted ?? this.musicMuted,
      sfxMuted: sfxMuted ?? this.sfxMuted,
       /// ⭐ สำคัญ
      padPlaying: padPlaying ?? this.padPlaying,
    );
  }
}