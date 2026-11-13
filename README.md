<div align="center">
    <img src="StockMonitor/Assets.xcassets/AppIcon.appiconset/icon_256x256.png" width="200" height="200">
    <h1>Stockbar</h1>
    <p>一款轻量级 macOS 菜单栏股票行情监控工具，支持 A股、港股、美股、韩股实时监控。</p>
    <br>
    <img src="https://img.shields.io/badge/版本-1.0.0-blue">
    <img src="https://img.shields.io/badge/平台-macOS%2013.5%2B-lightgrey?logo=apple">
    <img src="https://img.shields.io/badge/架构-arm64%20·%20x86__64-blue">
    <img src="https://img.shields.io/badge/Swift-5.9-orange?logo=swift">
    <img src="https://img.shields.io/badge/许可证-MIT-green">
</div>

---

## 截图

<div align="center">
    <img src="docs/screenshot.png">
</div>

---

## 功能特性

- **多市场支持** — 一个应用同时监控 A股（沪/深/北）、港股、美股、韩股
- **菜单栏常驻** — 极简悬浮于菜单栏，显示图标、实时价格及涨跌幅，不打扰日常工作
- **分时走势图** — 点击任意股票行，即可查看当日分钟级走势图
  - A股 / 港股：全天坐标轴（09:30 – 15:00 / 16:00）
  - 美股：含盘前+盘中+盘后完整坐标轴（04:00 – 20:00 ET）
- **美股时段标注** — 自动识别当前所处时段（夜盘 / 盘前 / 盘中 / 盘后），展示对应时段实时价及相对昨收涨跌幅
- **持仓盈亏跟踪** — 可为每只股票设置成本价和持仓股数，实时显示浮动盈亏和当日盈亏
- **到价提醒** — 给股票设一个目标价，涨到或跌到时弹出 macOS 系统通知；每只股票单独开关，提醒一次后自动关闭
- **观察仓** — 支持创建多个观察仓名单，随时切换关注重点
- **按涨跌幅排序** — 工具栏一键切换，按今日表现重新排序股票列表
- **涨跌颜色主题** — 支持中式（红涨绿跌）和欧美式（绿涨红跌）两种配色
- **数据持久化** — 股票列表保存至本地文件，自动备份，防止数据丢失
- **开机自启动** — 基于 `SMAppService` 注册登录项，可在设置中开关

---

## 系统要求

| | |
|---|---|
| **系统版本** | macOS 13.5（Ventura）及以上 |
| **架构** | Apple Silicon (arm64) · Intel (x86_64)，安装包分开提供 |

---

## 安装方法

1. 从 [Releases](../../releases) 页面下载对应架构的最新安装包：
   - `Stockbar-vX.X.X-arm64.dmg` — Apple Silicon（M 系列芯片）
   - `Stockbar-vX.X.X-x86_64.dmg` — Intel 芯片
2. 打开 DMG，将 **Stockbar.app** 拖入 **应用程序** 文件夹
3. 启动应用，菜单栏将出现股票图标

> **首次启动提示**：如果 macOS 提示“无法验证开发者”，请前往 **系统设置 → 隐私与安全性**，点击 **仍要打开**。

---

## 使用说明

设置界面分为三个标签页：**通用 / 股票 / 关于**。

### 添加股票

1. 点击菜单栏图标展开面板
2. 点击工具栏 **设置**（⚙）打开设置窗口，切换到 **股票** 标签页
3. 在搜索框输入股票名称或代码（如 `AAPL`、`腾讯`、`600000`、`005930.ks`）
4. 点击搜索结果即可添加到自选列表

### 设置持仓 / 到价提醒

1. 在 **股票** 标签页的“我的股票”中点击铅笔图标
2. 填写 **成本价** 和 **持仓股数**，股票行将实时显示浮动盈亏和当日盈亏
3. 填写 **目标价** 并勾选 **到价提醒**：目标价高于现价时等它涨到，低于现价时等它跌到
4. 到价后弹出系统通知，该提醒随即自动关闭（只提醒一次）；开启中的提醒在列表里显示 🔔

> 第一次开启时 macOS 会询问是否允许 Stockbar 发送通知，请点 **允许**；也可以在 **设置 → 通用 → 到价提醒** 发送测试通知确认。Stockbar 需要放在 **应用程序** 文件夹里才能收到通知。

### 分时走势图

点击面板中任意股票行即可打开分时图，点击左上角 **←** 返回列表。

### 状态栏显示

在 **设置 → 通用 → 状态栏显示** 中，可以选择在菜单栏显示哪只股票的行情，或选择 **“不显示”** 仅保留图标。

---

## 数据来源

所有数据均来自免费公开接口，**无需 API Key**。

| 数据源 | 用途 |
|--------|------|
| **新浪财经** (`hq.sinajs.cn`) | A股、美股实时行情；美股延伸时段价格 |
| **腾讯证券** (`qt.gtimg.cn`) | 港股实时行情 |
| **腾讯证券** (`web.ifzq.gtimg.cn`) | A股、港股分时走势数据 |
| **Yahoo Finance** (`query1.finance.yahoo.com`) | 韩股行情与分时走势数据（KRX） |
| **腾讯搜索** (`proxy.finance.qq.com`) | 股票搜索（主） |
| **新浪 Suggest** (`suggest3.sinajs.cn`) | 股票搜索（兜底） |

> 数据为免费公开接口，存在一定延迟，仅供个人参考，不构成任何投资建议。

---

## 本地构建

```bash
git clone https://github.com/gly/StockBar.git
cd StockBar
open StockMonitor.xcodeproj
```

选择 **Stockbar** Scheme，目标设为 **My Mac**，按 **⌘R** 运行。

分架构构建发布包（与 CI 一致）：

```bash
xcodebuild -scheme Stockbar -configuration Release \
  ARCHS="arm64" ONLY_ACTIVE_ARCH=NO
```

---

## CI/CD

推送到 GitHub 的 `v*` 标签（如 `v1.0.0`）会自动触发 GitHub Actions：

- 运行单元测试
- 分别构建 **arm64** 和 **x86_64** 两个安装包并做架构校验
- Ad-hoc 签名（保证系统通知权限可用）
- 打包 `Stockbar-vX.X.X-arm64.dmg` / `Stockbar-vX.X.X-x86_64.dmg` 并发布到 GitHub Releases

---

## 项目结构

```
StockMonitor/
├── Models/
│   ├── Stock.swift          # 股票模型（代码、名称、市场、成本、持仓、提醒）
│   ├── Quote.swift          # 行情模型（价格、涨跌、扩展时段价格）
│   ├── AppSettings.swift    # 用户配置（排序、分组、配色、货币等）
│   ├── Watchlist.swift      # 观察仓
│   └── PriceAlert.swift     # 到价提醒规则
├── State/
│   └── AppState.swift       # 全局状态、定时刷新、数据持久化与备份
├── Services/
│   ├── DataService.swift    # 实时行情抓取（新浪 / 腾讯 / Yahoo）
│   ├── ChartService.swift   # 分时数据抓取（腾讯 / Yahoo Finance）
│   ├── RefreshScheduler.swift
│   ├── OvernightService.swift   # 美股夜盘（Robinhood 公开行情）
│   ├── CurrencyService.swift    # 汇率换算
│   ├── NotificationService.swift # 系统通知
│   └── UpdateChecker.swift      # 检查更新
├── Utils/
│   ├── SettingsWindowController.swift # 设置独立窗口（预创建，秒开）
│   ├── LaunchAtLogin.swift  # 开机自启动（SMAppService）
│   └── KoreanStockID.swift  # 韩股代码映射
├── Views/
│   ├── MenuBarLabel.swift   # 菜单栏图标 + 行情显示
│   ├── DropdownView.swift   # 主面板
│   ├── StockRowView.swift   # 股票行
│   ├── StockGroupView.swift # 市场分组
│   ├── StockChartView.swift # 分时走势图
│   ├── SettingsView.swift   # 设置窗口（通用 / 股票 / 关于 三标签页）
│   ├── ToolbarView.swift    # 工具栏
│   └── ProfitSummaryView.swift
└── StockMonitorApp.swift    # App 入口 + AppDelegate
```

---

## 参与贡献

欢迎提交 Issue 和 Pull Request。对于较大的改动，建议先开 Issue 讨论方向。

---

## 许可证

[MIT](LICENSE)

---

## 免责声明

本项目仅供**个人学习和参考使用**。股票数据由第三方公开接口提供，可能存在延迟，作者不对任何基于本应用的投资决策承担责任。
