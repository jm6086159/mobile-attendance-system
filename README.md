Mobile Attendance System (Flutter)

Overview
- Fresh, minimal Flutter app that talks to your Laravel backend.
- Features: login (email or employee code + password), attendance history with month filter.

Quick start
1) Create platform folders (once):
   flutter create .

2) Configure API base URL in lib/config/api_config.dart
   - Desktop/web:   http://127.0.0.1:8000/api
   - Android emu:   http://10.0.2.2:8000/api
   - Device (LAN):  http://<your-pc-ip>:8000/api

3) Run:
   flutter pub get
   flutter run -d chrome   # or windows/android

Project layout
- lib/main.dart                 – app entry
- lib/config/api_config.dart    – base URL + endpoints
- lib/models/*.dart             – models
- lib/services/api_service.dart – HTTP client
- lib/providers/*.dart          – app state (auth/attendance)
- lib/screens/*.dart            – UI screens

# mobile-attendance-system
