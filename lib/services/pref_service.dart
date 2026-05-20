import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrefService {
  static const _musicVolumeKey = "musicVolume";
  static const _sfxVolumeKey = "sfxVolume";
  static const _musicMutedKey = "musicMuted";
  static const _sfxMutedKey = "sfxMuted";
  static const _fadeInKey = "fadeIn";
  static const _fadeOutKey = "fadeOut";

  Future<SharedPreferences> get _prefs async =>
      await SharedPreferences.getInstance();

  // ---------- SAVE ----------
  Future<void> saveMusicVolume(double v) async {
    final p = await _prefs;
    await p.setDouble(_musicVolumeKey, v);
  }

  Future<void> saveSfxVolume(double v) async {
    final p = await _prefs;
    await p.setDouble(_sfxVolumeKey, v);
  }

  Future<void> saveMusicMuted(bool v) async {
    final p = await _prefs;
    await p.setBool(_musicMutedKey, v);
  }

  Future<void> saveSfxMuted(bool v) async {
    final p = await _prefs;
    await p.setBool(_sfxMutedKey, v);
  }

  Future<void> saveFadeIn(int v) async {
    final p = await _prefs;
    await p.setInt(_fadeInKey, v);
  }

  Future<void> saveFadeOut(int v) async {
    final p = await _prefs;
    await p.setInt(_fadeOutKey, v);
  }

  // ---------- LOAD ----------
  Future<double> getMusicVolume() async {
    final p = await _prefs;
    return p.getDouble(_musicVolumeKey) ?? 0.5;
  }

  Future<double> getSfxVolume() async {
    final p = await _prefs;
    return p.getDouble(_sfxVolumeKey) ?? 0.5;
  }

  Future<bool> getMusicMuted() async {
    final p = await _prefs;
    return p.getBool(_musicMutedKey) ?? false;
  }

  Future<bool> getSfxMuted() async {
    final p = await _prefs;
    return p.getBool(_sfxMutedKey) ?? false;
  }

  Future<int> getFadeIn() async {
    final p = await _prefs;
    return p.getInt(_fadeInKey) ?? 1500;
  }

  Future<int> getFadeOut() async {
    final p = await _prefs;
    return p.getInt(_fadeOutKey) ?? 1500;
  }
}


final prefServiceProvider = Provider((ref) => PrefService());