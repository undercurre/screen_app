# 打包配置

## Android打包配置
1. 灵动渠道构建
* Release包
> flutter build apk --flavor LD --no-multidex --release --build-number <versionNumber> --build-name <versionName>

`打包产物保存的路径：`\build\app\outputs\apk\LD\release
* Debug包
> flutter build apk --flavor LD --no-multidex --debug --build-number <versionNumber> --build-name <versionName>

`打包产物保存的路径：`\build\app\outputs\apk\LD\debug


2. 晶华渠道构建
* Release包
> flutter build apk --flavor JH --no-multidex --release --build-number <versionNumber> --build-name <versionName>

`打包产物保存的路径：`\build\app\outputs\apk\JH\release
* Debug包
> flutter build apk --flavor JH --no-multidex --debug --build-number <versionNumber> --build-name <versionName>

`打包产物保存的路径：`\build\app\outputs\apk\JH\debug
