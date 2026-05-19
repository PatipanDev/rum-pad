# rum_tap

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


#การวางโครงสร้างโปรเจ็ค

lib/
├── core/                # เก็บสิ่งที่ใช้ร่วมกันทั้งแอป (Global)
│   ├── constants/       # เก็บค่าคงที่, สี, สไตล์
│   ├── errors/          # การจัดการ Error/Exception
│   ├── utils/           # ฟังก์ชันจิปาถะ (Formatter, Validator)
│   └── widgets/         # UI Widget ที่ใช้ซ้ำบ่อยๆ (เช่น CustomButton)
├── features/            # แบ่งตามฟีเจอร์ของแอป (เหมือนการแบ่ง Module)
│   ├── auth/            # ฟีเจอร์ล็อกอิน
│   │   ├── data/        # ติดต่อ API, Models
│   │   ├── logic/       # State Management (Bloc/Provider)
│   │   └── ui/          # หน้าจอ (Screens) และ Widget เฉพาะฟีเจอร์
│   └── dashboard/       # ฟีเจอร์หน้าหลัก
├── services/            # การเชื่อมต่อภายนอก (Firebase, Local DB, API Service)
└── main.dart            # จุดเริ่มต้นของแอป

## ล้างในคลัง
flutter pub cache clean
## รันแบบเอาเวอร์ชันใหม่
flutter run -d windows --vmservice-out-file=none
flutter pub get

## รัน windows
flutter run -d windows
## รัน androids
flutter run -d android
