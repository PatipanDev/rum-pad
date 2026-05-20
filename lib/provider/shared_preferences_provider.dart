import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 💡 สร้าง Provider สแตนด์บายรอไว้ (จะดึงค่ามาใส่ตอนเปิดแอปครั้งแรก)
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});