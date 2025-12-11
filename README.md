# 📱 English Learning Mobile App

Ứng dụng học tiếng Anh cho sinh viên với các tính năng quiz, flashcards, vocabulary practice, và nhiều hơn nữa.

---

## 🔧 Yêu Cầu Hệ Thống

### **Flutter & Dart**
- **Flutter:** 3.29.3 (stable)
- **Dart:** 3.7.2
- **Channel:** stable

### **Công Cụ**
- Git
- Android Studio hoặc VS Code
- Android SDK
- Java JDK 17+

---

## 🚀 Cài Đặt

### **1. Clone Repository**
```bash
git clone <repository-url>
cd mobile
```

### **2. Cài Dependencies**
```bash
flutter pub get
```

### **3. Chạy App**

**Web (Chrome):**
```bash
flutter run -d chrome
```

**Android:**
```bash
flutter run
```

**Build APK:**
```bash
flutter build apk --release
```

---

## 📦 Dependencies Chính

- `go_router` - Navigation
- `provider` - State management
- `dio` - HTTP client
- `cached_network_image` - Image caching
- `just_audio` - Audio playback
- `lottie` - Animations
- `flutter_animate` - UI animations
- `image_picker` - Image selection
- `permission_handler` - Permissions

---

## 🏗️ Cấu Trúc Project

```
lib/
├── data/              # Models & data layer
├── domain/            # Repositories & business logic
├── screens/           # UI screens
│   ├── admin/        # Admin screens
│   ├── auth/         # Authentication
│   ├── student/      # Student screens
│   └── teacher/      # Teacher screens
├── services/          # Services (auth, etc.)
├── shared_widgets/    # Reusable widgets
└── utils/            # Utilities & helpers
```

---

## 🎯 Tính Năng

### **Sinh Viên**
- ✅ Quiz (Multiple choice, Writing, Listening, Essay)
- ✅ Flashcards với pronunciation assessment
- ✅ Vocabulary practice
- ✅ Profile management với avatar upload
- ✅ Gift store
- ✅ Leaderboard
- ✅ Progress tracking

### **Giáo Viên**
- ✅ Quản lý lớp học
- ✅ Quản lý quiz
- ✅ Xem kết quả học sinh
- ✅ Lịch dạy

### **Admin**
- ✅ Quản lý người dùng
- ✅ Quản lý từ vựng
- ✅ Quản lý media
- ✅ Quản lý quà tặng

---

## ⚠️ Troubleshooting

### **Lỗi Flutter Version**
```bash
# Kiểm tra version
flutter --version

# Chuyển về version đúng
flutter version 3.29.3
```

### **Lỗi Dependencies**
```bash
flutter clean
flutter pub get
```

### **Lỗi Android Build**
```bash
cd android
./gradlew clean
cd ..
flutter pub get
```

---

## 📝 Ghi Chú Quan Trọng

1. **Đảm bảo Flutter version 3.29.3** trước khi chạy
2. Chạy `flutter doctor` để kiểm tra setup
3. File APK release: `build/app/outputs/flutter-apk/app-release.apk`

---

## 📞 Hỗ Trợ

Nếu gặp vấn đề khi setup, xem file [SETUP_GUIDE.md](./SETUP_GUIDE.md) để biết chi tiết.

---

## 📄 License

This project is for educational purposes.
