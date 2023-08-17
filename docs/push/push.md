# 推送接入教程

### 接入例子：
```dart

// 1.使用方法一
void changeRoomNameEvent(HomluxChangeRoomNameEven event) {
}
// 注册：改变房间名称事件
bus.typeOn(changeRoomNameEvent);
// 解注册：解除单个事件回调【不会影响此事件其他监听者】
bus.typeOff(changeRoomNameEvent);

// 2.使用方法二

// 注册：改变房间名称事件
bus.typeOn<HomluxChangeRoomNameEven>((args) => {

});
// 解注册：解除单个事件回调【会影响此事件监听者，全部都清空】
bus.typeOff<HomluxChangeRoomNameEven>();
```

## Homlux接入推送

homlux支持各种事件推送。灯组，场景，设备等等。

查看所有的事件类型路径如下：
> /lib/common/homlux/push/event/homlux_push_event.dart

## MeiJu接入推送

meiju支持设备删除，设备添加，设备解绑，设备属性变化等事件推送。
不支持灯组，场景等事件推送

查看所有的事件类型路径如下：
> /lib/common/meiju/push/event/meiju_push_event.dart

