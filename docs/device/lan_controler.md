# 需求背景
`场景`、`灯组`、`设备`在网络控制的基础上，再增加局域网控制。

# 功能清单

- 场景：
    1. 提供局域网场景列表
    2. 执行局域网场景

- 灯组：
    1. 提供局域网灯组列表
    2. 执行局域网灯组（开关、色温、亮度）
    3. 暂不提供灯组状态（开关、色温、亮度）

- 设备：
    1. 提供局域网设备列表
    2. 执行局域网设备（开关等各种功能）
    3. 提供查询单个设备状态

- 支持本地局域网下正常使用：
    1. 缓存云端数据
    2. 涉及缓存状态数据的修改

# 核心逻辑时序图
> 场景

- 局域网控制-时序图
```mermaid
sequenceDiagram
    participant 调用方
    participant HomluxSceneApi
    participant HomluxLanControlDeviceManager
    participant LanDeviceControlChannel
    调用方->>HomluxSceneApi: 下发控制场景指令
    HomluxSceneApi->>HomluxLanControlDeviceManager: 局域网控制
    HomluxLanControlDeviceManager --) HomluxLanControlDeviceManager: 检查是否可在局域网下控制
    HomluxLanControlDeviceManager->>LanDeviceControlChannel: 下发控制指令
    LanDeviceControlChannel--)HomluxSceneApi: 返回结果
    HomluxSceneApi->>调用方: 返回结果
```

- 云端控制-时序图
```mermaid
sequenceDiagram
    participant 调用方
    participant HomluxSceneApi
    participant HomluxApi
    调用方->>HomluxSceneApi: 下发控制场景指令
    HomluxSceneApi->>HomluxApi: 云端控制
    HomluxApi->>HomluxSceneApi: 返回结果
    HomluxSceneApi->>调用方: 返回结果
```

- 混合控制-逻辑图
```mermaid
graph LR
    A[开始] --> B[执行场景]
    B --> C{局域网是否可控}
    C -->|是| D{HomeOs执行指令}
    D --> |成功| F
    D --> |失败| E
    C -->|否| E[云端执行指令]
    E --> F[结束]
```

> 灯组

- 局域网控制-时序图
```mermaid
sequenceDiagram
    participant 调用方
    participant HomluxDeviceApi
    participant HomluxLanControlDeviceManager
    participant LanDeviceControlChannel
    调用方->>HomluxDeviceApi: 下发控制灯组指令
    HomluxDeviceApi->>HomluxLanControlDeviceManager: 局域网控制
    HomluxLanControlDeviceManager --) HomluxLanControlDeviceManager: 检查是否可在局域网下控制
    HomluxLanControlDeviceManager->>LanDeviceControlChannel: 下发控制指令
    LanDeviceControlChannel--)HomluxDeviceApi: 返回结果
    HomluxDeviceApi->>调用方: 返回结果
```

- 云端控制-时序图
```mermaid
sequenceDiagram
    participant 调用方
    participant HomluxDeviceApi
    participant HomluxApi
    调用方->>HomluxDeviceApi: 下发控制灯组指令
    HomluxSceneApi->>HomluxApi: 云端控制
    HomluxApi->>HomluxSceneApi: 返回结果
    HomluxSceneApi->>调用方: 返回结果
```

- 混合控制-逻辑图
```mermaid
graph LR
    A[开始] --> B[执行灯组]
    B --> C{局域网是否可控}
    C -->|是| D{HomeOs执行指令}
    D --> |成功| F
    D --> |失败| E
    C -->|否| E[云端执行指令]
    E --> F[结束]
```

> 设备

- 查询设备列表-逻辑图
```mermaid
graph LR
    A[开始] --> B[请求设备列表]
    B --> C[加载本地缓存数据]
    C --> D[遍历设备列表]
    D --> F{设备在局域网是否可控}
    F --> |否| F1[设置离在线状态为离线]
    F --> |是| F2[设置离在线状态为在线]
    F1 --> G
    F2 --> G[请求云端设备列表数据]
    G --> H[缓存云端数据到本地]
    H --> Z[结束]
```

- 查询单个设备状态-逻辑图

```mermaid
graph LR
    A[开始] --> |请求状态| B{局域网是否可控}
    B --> |是| C
    B --> |否| D
    C[返回局域网状态]
    D[返回云端状态]
    D --> E[缓存数据到本地]
    E --> F[结束]
    C --> F 
```

- 混合控制-逻辑图
```mermaid
graph LR
    A[开始] --> B[执行设备]
    B --> C{局域网是否可控}
    C -->|是| D{HomeOs执行指令}
    D --> |成功| F
    D --> |失败| E
    C -->|否| E[云端执行指令]
    E --> F[结束]
```

- 局域网设备状态推送-时序图

```mermaid
sequenceDiagram
    participant HomluxLanControlDeviceManager
    participant HomluxPushManager
    participant Card
    HomluxLanControlDeviceManager ->> HomluxPushManager: 设备状态发生更改
    HomluxPushManager ->> Card: 发送Event告知状态发生更改
    Card --) Card: 更新自身组件状态
```

- 云端设备装填推送-时序图


```mermaid
sequenceDiagram
    participant HomluxPushManager
    participant Card
    HomluxPushManager ->> Card: 发送Event告知状态发生更改
    Card --) Card: 更新自身组件状态
```

# 扩展与维护


