# 📱 Hướng Dẫn Setup Project Trên Máy Mới

## ✅ Yêu Cầu Hệ Thống

### **Flutter Version**
- **Flutter:** 3.29.3 (stable)
- **Dart:** 3.7.2
- **Channel:** stable

### **Công Cụ Cần Thiết**
- Git
- Android Studio (hoặc VS Code)
- Android SDK
- Java JDK 17+

---

## 🚀 Các Bước Setup

### **Bước 1: Cài Đặt Flutter Đúng Phiên Bản**

> **⚠️ QUAN TRỌNG:** Nếu máy đã có Flutter nhưng version khác, xem phần "Xử Lý Version Khác" bên dưới!

#### **Kiểm tra version hiện tại:**

```bash
flutter --version
```

**Kết quả mong muốn:**
```
Flutter 3.29.3 • channel stable
Dart 3.7.2
```

---

#### **Trường Hợp 1: Máy Chưa Có Flutter**

**Cách 1A: Sử dụng FVM (Flutter Version Management) - KHUYẾN NGHỊ**

```bash
# Cài FVM
dart pub global activate fvm

# Cài Flutter 3.29.3
fvm install 3.29.3

# Sử dụng phiên bản này cho project
cd mobile
fvm use 3.29.3

# Từ giờ dùng fvm flutter thay vì flutter
fvm flutter pub get
fvm flutter run
```

**Cách 1B: Cài Flutter Thủ Công**

1. Download Flutter 3.29.3:
   - Windows: https://docs.flutter.dev/release/archive
   - Tìm version 3.29.3 stable

2. Giải nén vào thư mục (ví dụ: `C:\flutter`)

3. Thêm vào PATH:
   - Mở "Environment Variables"
   - Thêm `C:\flutter\bin` vào PATH

4. Kiểm tra:
   ```bash
   flutter --version
   ```

---

#### **Trường Hợp 2: Máy Đã Có Flutter Nhưng Version Khác**

##### **Nếu Version CAO HƠN (ví dụ: 3.30.x, 3.31.x):**

**Option A: Downgrade Flutter (KHÔNG KHUYẾN NGHỊ - Có thể gây lỗi)**

```bash
# Xem các version có sẵn
flutter version

# Downgrade về 3.29.3
flutter downgrade 3.29.3
```

⚠️ **Lưu ý:** Downgrade có thể gây conflict với project khác trên máy!

---

**Option B: Sử dụng FVM (KHUYẾN NGHỊ NHẤT)**

```bash
# Cài FVM
dart pub global activate fvm

# Cài Flutter 3.29.3 (không ảnh hưởng Flutter global)
fvm install 3.29.3

# Trong project, dùng version này
cd mobile
fvm use 3.29.3

# Chạy với FVM
fvm flutter pub get
fvm flutter run
```

✅ **Ưu điểm:**
- Không ảnh hưởng Flutter global
- Có thể dùng nhiều version Flutter khác nhau cho các project
- An toàn nhất!

---

**Option C: Thử Chạy Với Version Cao Hơn (RỦI RO)**

```bash
# Thử chạy trực tiếp
flutter pub get
flutter run
```

⚠️ **Rủi ro:**
- Có thể gặp lỗi dependencies
- Một số package có thể không tương thích
- **CHỈ NÊN THỬ** nếu không có cách khác

**Nếu gặp lỗi:**
```bash
# Thử upgrade dependencies
flutter pub upgrade

# Nếu vẫn lỗi → Dùng Option A hoặc B
```

---

##### **Nếu Version THẤP HƠN (ví dụ: 3.27.x, 3.28.x):**

```bash
# Upgrade Flutter
flutter upgrade

# Hoặc upgrade đến version cụ thể
flutter upgrade 3.29.3
```

---

#### **Trường Hợp 3: Không Muốn Động Đến Flutter (AN TOÀN NHẤT)**

**→ SỬ DỤNG APK ĐÃ BUILD!**

1. Copy file `app-release.apk` từ `build/app/outputs/flutter-apk/`
2. Cài trực tiếp lên Android device/emulator
3. **KHÔNG CẦN** Flutter, build gì cả!

---

### **Bước 2: Clone Project**

```bash
# Clone repository
git clone <repository-url>
cd mobile

# Kiểm tra branch
git branch
```

---

### **Bước 3: Cài Dependencies**

```bash
# Lấy packages
flutter pub get

# Clean (nếu cần)
flutter clean
flutter pub get
```

---

### **Bước 4: Setup Android**

```bash
# Kiểm tra Android setup
flutter doctor

# Chấp nhận licenses (nếu cần)
flutter doctor --android-licenses
```

---

### **Bước 5: Chạy App**

#### **Trên Chrome (Web)**
```bash
flutter run -d chrome
```

#### **Trên Android Emulator**
```bash
# Mở emulator trước
flutter emulators --launch <emulator-name>

# Chạy app
flutter run
```

#### **Build APK**
```bash
flutter build apk --release
```

---

## ⚠️ Troubleshooting

### **Lỗi 1: Flutter Version Không Khớp**

**Triệu chứng:**
```
Error: The current Flutter SDK version is X.X.X
This project requires Flutter SDK version 3.29.3
```

**Giải pháp:**
```bash
# Sử dụng FVM
fvm use 3.29.3

# Hoặc cài đúng version
flutter version 3.29.3
```

---

### **Lỗi 2: Gradle Build Failed**

**Triệu chứng:**
```
FAILURE: Build failed with an exception
```

**Giải pháp:**
```bash
# Clean project
flutter clean

# Xóa build cache
cd android
./gradlew clean
cd ..

# Build lại
flutter pub get
flutter run
```

---

### **Lỗi 3: Package Version Conflicts**

**Triệu chứng:**
```
Because project depends on package_a >=1.0.0 and package_b...
```

**Giải pháp:**
```bash
# Xóa pubspec.lock
rm pubspec.lock

# Get lại
flutter pub get

# Nếu vẫn lỗi, upgrade
flutter pub upgrade
```

---

### **Lỗi 4: Android Licenses**

**Triệu chứng:**
```
Android sdkmanager not found
```

**Giải pháp:**
```bash
flutter doctor --android-licenses
# Nhấn 'y' để chấp nhận tất cả
```

---

## 📝 Checklist Trước Khi Demo

- [ ] Flutter version: 3.29.3
- [ ] `flutter doctor` không có lỗi
- [ ] `flutter pub get` thành công
- [ ] App chạy được trên Chrome
- [ ] App chạy được trên Android emulator
- [ ] Build APK thành công
- [ ] Test các tính năng chính:
  - [ ] Login
  - [ ] Profile (upload avatar)
  - [ ] Quiz (làm bài và nộp)
  - [ ] Audio playback
  - [ ] Gift store

---

## 🎯 Lưu Ý Quan Trọng

### **1. Không Commit `pubspec.lock`?**
- ✅ **NÊN commit** `pubspec.lock` để đảm bảo dependencies giống nhau
- Đã có trong `.gitignore`? → Xóa dòng `pubspec.lock` khỏi `.gitignore`

### **2. Flutter SDK Path**
- Mỗi máy có thể có path khác nhau
- Không cần lo, Flutter tự detect

### **3. Android SDK**
- Đảm bảo Android SDK đã cài đặt
- Chạy `flutter doctor` để kiểm tra

### **4. Internet Connection**
- Cần internet để download packages lần đầu
- Sau đó có thể offline

---

## 🆘 Nếu Vẫn Gặp Vấn Đề

### **Option 1: Sử dụng Docker (Advanced)**
Tạo Dockerfile với Flutter 3.29.3 để đảm bảo môi trường giống hệt nhau.

### **Option 2: Mang Theo Flutter SDK**
- Copy toàn bộ thư mục Flutter SDK
- Paste vào máy mới
- Update PATH

### **Option 3: Build APK Trước**
- Build APK trên máy hiện tại
- Copy file APK sang máy demo
- Cài trực tiếp (không cần build lại)

---

## 📦 File APK Đã Build

**Location:** `build/app/outputs/flutter-apk/app-release.apk`

**Cách sử dụng:**
1. Copy file APK sang máy mới
2. Cài trực tiếp lên Android device/emulator
3. Không cần setup Flutter!

**Lưu ý:** APK chỉ dùng để demo, không dùng để develop.

---

## 🎓 Tips Cho Ngày Báo Cáo

1. **Test trước 1 ngày:**
   - Clone project trên máy bạn
   - Chạy thử tất cả tính năng

2. **Backup APK:**
   - Mang theo file APK đã build
   - Phòng trường hợp không build được

3. **Chuẩn bị slides:**
   - Screenshot các tính năng
   - Video demo (nếu có)

4. **Hiểu rõ code:**
   - Xem lại các file chính
   - Chuẩn bị giải thích architecture

Good luck! 🍀
