# 打包配置

## Android打包配置
1. 灵动渠道构建
* Release包
> flutter build apk --flavor LD --no-multidex --dart-define=env=prod --release --build-number <versionNumber> --build-name <versionName>

`打包产物保存的路径：`\build\app\outputs\apk\LD\release

* Debug包
> flutter build apk --flavor LD --no-multidex --dart-define=env=prod --debug --build-number <versionNumber> --build-name <versionName>

`打包产物保存的路径：`\build\app\outputs\apk\LD\debug


2. 晶华渠道构建
* Release包
> flutter build apk --flavor JH --no-multidex --dart-define=env=prod --release --build-number <versionNumber> --build-name <versionName>

`打包产物保存的路径：`\build\app\outputs\apk\JH\release

* Debug包
> flutter build apk --flavor JH --no-multidex --dart-define=env=prod --debug --build-number <versionNumber> --build-name <versionName>
> flutter build apk --flavor LD --no-multidex --dart-define=env=prod --debug --build-number 2320 --build-name 2320
`打包产物保存的路径：`\build\app\outputs\apk\JH\debug

*** 注意: `--dart-define=env`为指定环境变量，值为`prod`正式环境，值为`sit`测试环境

## adb传输命令

adb install -r -d <上面命令输出的打包路径>

#### 因远程依赖库关闭，服务器资源吃紧等因素，运行Android端代码需要做以下的配置。
#### 后期nexus服务器开启，可忽略此教程
### Maven迁移到本地教程
1. 在系统环境变量中配置本地maven仓库地址，示例如下：
> 变量名：MAVEN_LOCAL_ADDRESS 变量值: file:///D:/MyData/weinp1/.m2/repository/
2. 让安卓端同事共享一份maven仓库文件