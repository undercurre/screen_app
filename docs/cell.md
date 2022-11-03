# 列表-单元行

### 简介
类似 `dof-cell`
当 titleSlot 非空，title desc tag 也赋值时，会抛出异常提示；
反之，titleSlot 与 title 同时为空，也会抛出异常。

### widget结构
┏━━━━━━━━━━━━┳━━━━━━━━━━━┳━━━━━━ BoxDecoration ━━┳━━━━━━━━━━━┳━━━━━━━━┳━━━━━━━┓
┃            ┃middleCell ┃           ┃           ┃           ┃        ┃       ┃
┃            ┃┌─────┬───┐┃           ┃           ┃           ┃        ┃       ┃
┃ avatarIcon ┃│title│tag│┃ rightSlot ┃ rightText ┃ rightIcon ┃ Switch ┃ Arrow ┃
┃            ┃├─────┴───┤┃           ┃           ┃           ┃        ┃       ┃
┃            ┃│   desc  │┃           ┃           ┃           ┃        ┃       ┃
┃            ┃└─────────┘┃           ┃           ┃           ┃        ┃       ┃
┃            ┃┌─────────┐┃           ┃           ┃           ┃        ┃       ┃
┃            ┃│titleSlot│┃           ┃           ┃           ┃        ┃       ┃
┃            ┃└─────────┘┃           ┃           ┃           ┃        ┃       ┃
┗━━━━━━━━━━━━┻━━━━━━━━━━━┻━━━━━━━━━━━┻━━━━━━━━━━━┻━━━━━━━━━━━┻━━━━━━━━┻━━━━━━━┛

### 基本用法

```dart
Cell(
  titleSlot: const Text('自定义标题布局及样式'),
)

Cell(
    title: 'Midea-smart',
    tag: '我创建的',
    desc: '房间4',
    bgColor: Colors.black,
    avatarIcon: Icon(Icons.wifi_outlined, color: Colors.white),
    rightIcon: Icon(Icons.lock_outline_sharp, color: Colors.white),
    hasArrow: true,
    hasTopBorder: true,
    hasBottomBorder: true,
    hasTopBorder: true,
    hasSwitch: true,
    initSwitchValue: true,
    rightText: '6°C',
    onSwitch: (value) => logger.i(value),
    onTap: () => logger.i('onTap'),
    onLongPress: () => logger.i('onLongPress')
)
```

### 参数配置
| Prop | Type | Required | Default | Description |
|------|------|----------|---------|-------------|
| title | `String` |`No`| '' | 标题  |
| titleSlot | `Widget` |`No`| - | 标题插槽，自定义标题布局及样式  |
| rightSlot | `Widget` |`No`| - | 右侧插槽，自定义右侧布局及样式  |
| desc | `String` |`No`| - | 描述  |
| tag | `String` |`No`| - | 标签、标注，带固定样式的圆角文字背景  |
| titleColor | `Color` |`No`| `Colors.white` | 标题颜色  |
| titleSize | `double` |`No`| `20.0` | 标题大小  |
| fontWeight | `FontWeight` |`No`| `FontWeight.normal` | 标题粗细  |
| titleMaxLines | `int` |`No`| `2` | 标题最大行数，超出长度则截断并显示...  |
| bgColor | `Color` |`No`| `Colors.black` | 背景颜色  |
| avatarIcon | `Widget` |`No`| - | 左侧图标，类型扩大为Widget，也可传入 Image |
| rightIcon | `Widget` |`No`| - | 右侧图标，同上  |
| rightText | `String` |`No`| - | 显示右边文本  |
| hasArrow | `Boolean` |`No`| `false` | 是否显示右箭头  |
| hasSwitch | `Boolean` |`No`| `false` | 是否显示右边Switch  |
| initSwitchValue | `Boolean` |`No`| `false` | Switch初始值  |
| borderColor | `Color` |`No`| `const Color.fromRGBO(151, 151, 151, 0.2)` | 边框颜色，包括上下边框  |
| hasTopBorder | `Boolean` |`No`| `false` | 是否显示上边框  |
| hasBottomBorder | `Boolean` |`No`| `false` | 是否显示下边框  |

### 事件
| EventName | Type | Required |  Description |
|------|------|----------|--------------|
| onSwitch | `ValueChanged<bool>` | `No` | switch 变化时触发 |
| onTap | `Function` | `No` | 点击行时触发 |
| onLongPress | `Function` | `No` | 长按行时触发 |