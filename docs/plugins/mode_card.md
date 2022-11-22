# 模式卡片

## 简介
卡片列表，模式单选还是多选，逻辑需要调用者进行处理。（单选参考0x13插件，多选参考0x26插件）

## 属性

| 参数name       | 类型                 | 必传    | 默认值                                  | 描述             |
|--------------|--------------------|-------|--------------------------------------|----------------|
| modeList     | List<Mode>         | true  | -                                    | 模式列表           |
| selectedKeys | Map<String, bool?> | true  | -                                    | key为true模式将会高亮 |
| padding      | EdgeInsetsGeometry | false | EdgeInsets.only(top: 18, bottom: 16) | 卡片内边距          |
| spacing      | double             | false | 22                                   | 主轴元素间距         |
| runSpacing   | double             | false | 41                                   | 两行之间间距         |

## 事件

| 参数name | 类型                       | 必传    | 描述     |
|--------|--------------------------|-------|--------|
| onTap  | void Function(Mode mode) | false | 模式点击事件 |

