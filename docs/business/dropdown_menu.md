# 通用下拉选择组件

## 简介

传入菜单项项、触发弹出菜单的组件，用户点击即可触发下拉菜单。

## 属性

| 参数name    | 类型                            | 必传    | 默认值                         | 描述        |
|-----------|-------------------------------|-------|-----------------------------|-----------|
| menu      | List<PopupMenuEntry<dynamic>> | true  |                             | 菜单项       |
| trigger   | Widget                        | true  |                             | 触发弹出菜单的组件 |
| position  | RelativeRect                  | false | 通过菜单宽度trigger长度进行计算         | 滑动条最小值    |
| duration  | Duration                      | false | Duration(milliseconds: 300) | 动画时长      |
| menuWidth | double                        | false | 140                         | 菜单宽度      |
| hideArrow | bool                          | false | false                       | 是否显示箭头    |

## 事件

| 参数name          | 类型                            | 必传    | 描述           |
|-----------------|-------------------------------|-------|--------------|
| onSelected      | void Function(dynamic result) | false | 选中或者点击其他地方触发 |
| onVisibleChange | void Function(bool visible)   | false | 菜单是否展示       |

