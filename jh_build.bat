@echo off
echo 切换脚本启动
cd
adb root
flutter build apk --flavor JH --multidex --dart-define=env=prod --release --build-number 20 --build-name 0149
echo
pause