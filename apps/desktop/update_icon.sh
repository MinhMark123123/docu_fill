#!/bin/bash

# Đảm bảo đang ở đúng thư mục
cd "$(dirname "$0")"

echo "📦 Đang cài đặt dependencies..."
flutter pub get

echo "🎨 Đang khởi tạo App Icon cho Desktop (macOS, Windows, Linux)..."
dart run flutter_launcher_icons

echo "✅ Hoàn tất! Nếu bạn đã mở ứng dụng trước đó, hãy build lại để thấy icon mới."
