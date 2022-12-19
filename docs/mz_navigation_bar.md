# 导航组件

## 简介
通用的顶部导航组件

## widget结构
```markdown
┏━━━━━━━━━━━━━━ MzNavigationBar ━━━━━━━━━━━━━━━┓
│ ┌─────────┬─────────────────────┬──────────┐ │
│ │ LeftBtn │ ┌───────┬─────────┐ │ PowerBtn │ │
│ │         │ │ title │ loading │ │ rightSlot│ │
│ │         │ ├───────┴─────────┤ │          │ │
│ │         │ │ desc            │ │          │ │
│ │         │ └─────────────────┘ │          │ │
│ └─────────┴─────────────────────┴──────────┘ │
└──────────────────────────────────────────────┘
```

## 属性

| 参数name | 类型     | 必传    | 默认值 | 描述        |
|--------|--------|-------|--|-----------|
| title  | String | false | `''` | 导航栏标题  |
| desc   | String | false | `''` | 导航栏标题下的描述  |
| hasPower  | Widget | false  | - | 是否显示开关按钮 |
| power  | Widget | false  | - | 开关按钮值 |
| isLoading  | bool | false  | - | 是否显示加载中图标 |
| hasBottomBorder  | bool | false  | - | 是否显示下分隔线 |
| rightSlot | Widget | false | - | 右按钮插槽，与hasPower互斥 |
| sideBtnWidth | double | true | 70 | 顶部双侧按钮的占位宽度 |

## 事件

| 参数name        | 类型              | 必传    | 描述       |
|---------------|-----------------|-------|----------|
| onLeftBtnTap  | void Function() | false | 左侧按钮点击事件  |
| onRightBtnTap | void Function() | false | 右侧按钮点击事件 |
