# 设备卡片——>插件

## 配置（./device/config.dart）
插件的扩展将使用配置的方式进行添加

DeviceOnList：待使用设备定义（被定义的设备是已有实物的实体）
|成员|是否可选|说明|示例|
|:-|:-:|:-:|-:|
|name|否|设备名称|吸顶灯|
|onIcon|否|打开设备时卡片上的图标|assets/imgs/device/dengguang_icon_on.png|
|offIcon|否|关闭设备时卡片上的图标|assets/imgs/device/dengguang_icon_off.png
|type|否|品类码|0x13|
|apiCode|是|使用interface时用索引|0x13|
|modelNum|是|zigbee设备传入用于过滤|[1076,1088]|
|sn8s|是|wifi设备传入用于过滤|[79009833,22222222]|
|powerKey|是|设备的power字段|power|
|powerValue|是|设备打开时power的值|'on'|
|attrName|是|卡片的数值|brightValue|
|attrUnit|是|卡片上数值使用的单位符|%|
|attrFormat|是|卡片上数值使用时的过滤器|(num / 255  * 100).toInt()|

deviceConfig     定义待使用设备

supportDeviceList 插件支持的设备

statusDeviceList 卡片支持显示数值的设备

serviceList 供卡片使用的服务列表（注意：这是个Map<apiCode,DeviceInterface>）

## 接口
在./plugins/device_interface.dart中定义了插件对接设备卡片所需要的获取状态：detail 的方法（用于存储设备状态到Global）和开关设备：power 的方法（用于设备卡片的开关按钮）

所以插件的api中必须实现getDeviceDetail和setPower这两个方法

## plugins文件夹——插件储存区的结构

```
└── plugins // 插件存储区
        └── 0x13_pdm // 品类码(使用物模型)
                ├── api // 插件使用到的接口
                ├── index // 插件主页面
                ├── mode_list // 插件模式配置
                └── service // 插件基于接口实现的服务（可与api进行合并）
        └── 0x13_lua // 品类码（使用lua）
                ├── api // 插件使用到的接口
                ├── index // 插件主页面
                ├── mode_list // 插件模式配置
                └── service // 插件基于接口实现的服务（可与api进行合并）
```
