# pixel-fight

一款 vibe coding 生成的网页 P2P 格斗游戏

## 像素风对战游戏 v2.1.0

### 游戏介绍

一款像素风格的 P2P 联机对战游戏，支持单人模式和双人联机对战。纯前端实现，无需注册、无需服务器，打开网页就能玩！

### 在线演示

[![GitHub Pages](https://img.shields.io/badge/GitHub%20Pages-Live-green)](https://loginyourheart.github.io/mecha-fight/)

在线体验：https://loginyourheart.github.io/mecha-fight/

### ⚠️ 重要提示

本游戏必须运行在HTTP服务器上！使用本地文件路径（file://）可能导致部分功能异常，推荐使用任意HTTP服务器（如 Python 的 http.server、VS Code 的 Live Server、GitHub Pages 等）运行。

### 版本说明

v2.1.0 主要更新：

- **攻击动画修复**：
  - 修复双动画bug（attackWindup未清零导致一次攻击播放两次动画）
  - 修复recovery阶段手臂/腿部动画方向反了的问题
  - 移除windup/recovery阶段的sin振荡，消除站立腿抖动
- **日志面板重构**：
  - 统一为标签页切换（同步日志/战斗日志）
  - Backquote(`)/F2 均可切换面板，右上角有📋按钮
  - 添加绘制追踪日志 DRAW_WINDUP/ACTIVE/RECOVERY
  - 复制成功有按钮反馈提示
- **房间系统修复**：
  - 修复短英文名无法创建房间的bug（Base64的=号PeerJS不兼容）
  - 修复幽灵房间（过滤mf_开头的临时连接ID）
- **性能优化**：
  - 网络同步间隔提升至16ms（≈60fps）
  - 跳跃高度调整（jumpForce=13）
  - 位置插值threshold降至1px
  - 重力系数调整（GRAVITY=0.4）
- **UI调整**：
  - 按键说明移到右侧竖排显示
  - 游戏标题改为"像素风P2P对战"
  - 新增STUN服务器测试工具（stun-tester.html）
  - 临时工具归入tmptools目录

v2.0.1 主要更新：

- **rematch（再战一局）同步问题完全修复**：
  - 只有主机（isHost）能调用游戏开始逻辑！
  - 客机只等待主机的 game_state_sync！
- **目录结构优化**：
  - 添加 .gitignore 忽略不必要文件
- **版本号统一**：
  - 版本号统一在 GAME_VERSION 常量（v2.0.1）

v2.0.0 主要更新：

- **同步架构完全重构（格斗游戏模式）**：
  - 主机是血量权威，完全避免血量同步冲突
  - 气值完全本地控制（不再网络同步互相覆盖）
  - state_update 只发送血量，不再包含气值！
  
- **气值实时同步**：
  - 玩家按住 S 站着不动时，气值实时同步（position 消息里带！）
  
- **火球碰撞判定修复**：
  - 只有主机执行伤害判定！客机完全信任
  - 解决客机攻击无法造成伤害的问题
  
- **客机本地火球动画**：
  - 客机自己发的火球本地能看到了！
  
- **气值显示和发送一致**：
  - updateQiUI 用 Math.round （和发送时一致，避免差1）
  
- **对手位置更平滑**：
  - lerp 系数从 0.3 提高到 0.45！

v1.2.0 主要更新：

- 配置驱动架构，支持 MOVES/CHARACTERS/CHARACTER_CONTROLS 声明
- 修复防御同步bug（使用prevDefending比较）
- 统一联机控制
- 修复等待房间UI，未准备玩家显示黄色指示器
- 版本号集中在 GAME_VERSION 常量

### 操作说明

**单人模式（本地对战）**：
- 玩家1（红方）：A/D 移动，W 跳跃，G 拳攻击，H 腿攻击，J 防御，Y 气功弹
- 玩家2（蓝方）：←/→ 移动，↑ 跳跃，L 拳攻击，; 腿攻击，' 防御，P 气功弹

**联机模式**：
- A/D 移动，W 跳跃，J 拳攻击，K 腿攻击，I 气功弹，L 防御
- **S键**：攒气（按住站着不动就能攒气！）
- **超级火球**：100气时按 I

### 游戏特色

- 像素风格画面
- 实时P2P联机对战（无需注册，无需服务器）
- 流畅的战斗体验（60fps位置同步）
- 多种攻击方式
- 防御反击机制
- 气值系统（普通火球/超级火球）
- 屏幕震动、击飞效果

### 技术说明

- 使用 PeerJS 实现 P2P WebRTC 联机
- 无需公网服务器，仅需信令服务器（使用公共 PeerJS 服务器或自建）
- 适合局域网或具有NAT穿透条件的网络环境
- 位置同步使用 Lerp 平滑插值 + 60fps高频同步
- 内置STUN服务器延迟测试工具（stun-tester.html）

### 自建信令服务器

如果你想使用自己的信令服务器，可以使用以下开源项目：

[![SignalServer](https://img.shields.io/badge/SignalServer-GitHub-blue)](https://github.com/loginyourheart/SignalServer)

**SignalServer** - 轻量级 PeerJS 信令服务器（使用 Rust 编写）

- 高性能、低内存占用
- 简单易用的配置
- 完全开源，可自行托管
- 提供预编译的 Release 二进制文件，可直接下载使用

**方式一：下载预编译版本（推荐）**

从 [SignalServer Releases](https://github.com/loginyourheart/SignalServer/releases) 下载对应平台的二进制文件，解压后直接运行即可：

```bash
# Linux
./signal-server

# Windows
signal-server.exe

# macOS
./signal-server
```

**方式二：自行编译**

```bash
git clone https://github.com/loginyourheart/SignalServer.git
cd SignalServer
cargo build --release
cargo run --release
```

**配置说明**

服务器默认监听 `0.0.0.0:9000`，可在 `config.toml` 或环境变量中修改端口等参数。详细说明请参考 [SignalServer 项目主页](https://github.com/loginyourheart/SignalServer)。

配置好后，在游戏内点击设置按钮（齿轮图标），填入你的服务器地址和端口即可使用。

### 版本历史

- **v2.1.0** - 攻击动画修复、日志面板重构、房间系统修复、60fps同步、UI优化！
- **v2.0.1** - 修复rematch同步问题，目录结构优化，版本号统一！
- **v2.0.0** - 同步架构重构，气值系统完善，修复所有同步问题！
- **v1.2.0** - 配置驱动架构，修复防御同步，统一联机控制
- **v1.1.1** - 完善防御同步，优化位置平滑，添加实时日志面板
- **v1.1.0** - 优化网络通信，添加日志导出功能
- **v1.0.9** - 优化网络通信效率
- **v1.0.8** - 修复联机模式下客机端无法发送位置同步的问题