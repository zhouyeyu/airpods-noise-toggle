# AirPods Noise Toggle for macOS

双击 Option 键快速切换 AirPods Pro 降噪模式（降噪 ↔ 自适应）

## 功能

- 双击 Option 键触发
- 在 **降噪** 和 **自适应** 模式之间切换
- 屏幕显示切换结果提示

## 安装

### 1. 安装 Hammerspoon

```bash
brew install --cask hammerspoon
```

### 2. 复制配置文件

```bash
mkdir -p ~/.hammerspoon
cp init.lua ~/.hammerspoon/init.lua
```

或者手动将 `init.lua` 复制到 `~/.hammerspoon/` 目录。

### 3. 启动 Hammerspoon

```bash
open /Applications/Hammerspoon.app
```

### 4. 授予辅助功能权限

首次运行需要授权：

1. 打开 **系统设置**
2. 进入 **隐私与安全性** → **辅助功能**
3. 找到 **Hammerspoon** 并勾选

## 使用

快速 **双击 Option 键** 即可切换降噪模式。

## 自定义

### 修改切换的模式

编辑 `init.lua`，找到以下部分：

```lua
-- AirPods Pro 聆听模式: 通透(4) / 自适应(5) / 降噪(6)
set adaptiveCheckbox to item 5 of allCheckboxes  -- 自适应
set ancCheckbox to item 6 of allCheckboxes       -- 降噪
```

索引对应关系（从声音菜单展开后的顺序）：
- `4` = 通透模式
- `5` = 自适应
- `6` = 降噪

### 修改 AirPods 位置

如果你的 AirPods 不在声音菜单的第 3 个位置，修改这行：

```lua
set airpodsCheckbox to item 3 of allCheckboxes
```

### 修改双击间隔

```lua
local doubleClickThreshold = 0.3 -- 秒
```

## 兼容性

- macOS 26 (Tahoe) 测试通过
- 需要 AirPods Pro（带主动降噪功能）
- 需要菜单栏显示"声音"图标

## 原理

通过 Hammerspoon 监听键盘事件，检测到双击 Option 后执行 AppleScript，自动点击声音菜单切换降噪模式。

## License

MIT
