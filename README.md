# UISpec - AI 时代的 UI 规范管理系统

[![Version](https://img.shields.io/badge/version-2.0.0-blue.svg)](https://github.com/lgh-dev/uispec)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Shell](https://img.shields.io/badge/shell-bash-orange.svg)](https://www.gnu.org/software/bash/)

## 简介

UISpec 是专为 AI 编程助手设计的 UI 规范管理系统。通过简单的命令，让 AI 生成的界面始终保持一致的设计语言。

### ✨ 特性

- 🚀 **极速安装** - 纯 Shell 脚本，无需编译，秒级安装（仅 32KB）
- 🎨 **多规范支持** - 内置 5 套专业设计规范
- 🤖 **AI 工具集成** - 支持 Claude Code 和 Qoder
- 📦 **零依赖** - 仅需系统自带的 bash
- 🔧 **三个核心命令** - 简单易用的工作流

## 快速开始

### 安装

```bash
# 一键安装
curl -fsSL https://raw.githubusercontent.com/lgh-dev/uispec/main/install.sh | bash
```

### 卸载

```bash
# 一键卸载（需要用户确认）
curl -fsSL https://raw.githubusercontent.com/lgh-dev/uispec/main/uninstall.sh | sudo bash

# 自动确认卸载（跳过交互）
curl -fsSL https://raw.githubusercontent.com/lgh-dev/uispec/main/uninstall.sh | bash -s -- -y
```

**安全提示**：卸载脚本会显示将要删除的内容，并要求用户输入 `y` 确认后才会执行。

### 初始化

```bash
# 初始化到 Claude Code
uispec init claude

# 初始化到 Qoder
uispec init qoder

# 同时初始化到所有平台
uispec init all
```

### 使用

重启 AI 工具后，即可使用以下命令：

- `/uispec-switch` - 选择设计规范
- `/uispec-do` - 按规范开发功能
- `/uispec-check` - 审查代码合规性

## 设计规范

UISpec 内置 5 套专业设计规范：

| 规范 | 适用场景 | 特点 |
|------|----------|------|
| **Modern Minimal** | SaaS产品、工具应用 | 简约、清晰、高效 |
| **Dark Elegant v2** | 开发IDE、设计工具 | 精致、神秘、高对比 |
| **Creative Playful** | 教育产品、创意工具 | 活泼、有趣、富有创意 |
| **Professional Business** | 企业应用、金融产品 | 专业、可信、稳重 |
| **Vibrant Tech** | 科技产品、游戏平台 | 动感、未来、创新 |

### Dark Elegant v2.2.0 特性

最新优化的 Dark Elegant 规范包含：
- **5级色彩层次系统**：背景、文字、边框各5级精细控制
- **完整组件规范**：按钮、输入框、卡片等40+组件
- **双重阴影系统**：基础阴影 + 发光效果
- **专业动画系统**：3种时长、3种缓动曲线
- **无障碍支持**：WCAG AAA 对比度标准

## 命令说明

### UISpec CLI 命令

```bash
# 查看状态
uispec status

# 卸载
uispec uninstall claude
uispec uninstall qoder
uispec uninstall all

# 查看版本
uispec -v

# 查看帮助
uispec -h
```

### AI 工具命令详解

#### /uispec-switch - 切换设计规范

快速切换项目使用的设计规范：

```bash
# 直接指定规范
/uispec-switch dark-elegant

# 不带参数显示选择列表
/uispec-switch
```

#### /uispec-do - 按规范开发

使用选定规范开发功能，AI 会严格遵循：
- 色彩系统（主色、辅助色、状态色）
- 间距系统（4px 基数的倍数）
- 字体排版（Inter + JetBrains Mono）
- 组件样式和交互状态

```bash
/uispec-do 创建一个登录表单
```

#### /uispec-check - 审查合规性

审查代码是否符合规范：

```bash
/uispec-check
# AI 会给出详细的审查报告和改进建议
```

## 项目结构

```
uispec/
├── shell/              # Shell 脚本实现
│   ├── uispec.sh       # 主入口
│   ├── lib/           # 库文件
│   │   ├── colors.sh  # 颜色输出
│   │   ├── config.sh  # 配置管理
│   │   └── download.sh # 下载功能
│   └── commands/      # 命令实现
│       ├── init.sh    # 初始化
│       ├── status.sh  # 状态查看
│       └── uninstall.sh # 卸载
├── specs/             # 设计规范文件
│   ├── modern-minimal.md
│   ├── dark-elegant.md (v2.2.0)
│   ├── creative-playful.md
│   ├── professional-business.md
│   └── vibrant-tech.md
├── commands/          # AI 工具命令
│   ├── uispec-switch.md
│   ├── uispec-do.md
│   └── uispec-check.md
├── install.sh         # 安装脚本
└── uispec-website.html # 项目官网
```

## 系统要求

- **操作系统**: macOS 或 Linux
- **Shell**: Bash 3.2+
- **网络工具**: curl 或 wget
- **可选**: Git

## 开发

```bash
# 克隆项目
git clone https://github.com/lgh-dev/uispec.git
cd uispec

# 本地测试
./shell/uispec.sh status

# 开发模式运行
./shell/uispec.sh init claude
```

## 版本历史

- **v2.0.0** (2024-12-24)
  - 完全重写为 Shell 脚本
  - 体积减小 99.94%（57MB → 32KB）
  - 安装速度提升 45x
  - 零依赖，纯 bash 实现

- **v1.0.0** (2024-12-24)
  - 初始版本，基于 Bun

## 贡献

欢迎贡献新的设计规范或改进建议！

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/amazing-spec`)
3. 提交更改 (`git commit -m 'Add amazing spec'`)
4. 推送到分支 (`git push origin feature/amazing-spec`)
5. 创建 Pull Request

## 许可

[MIT License](LICENSE)

## 链接

- [项目主页](https://github.com/lgh-dev/uispec)
- [问题反馈](https://github.com/lgh-dev/uispec/issues)
- [设计规范文档](specs/)
- [在线演示](https://lgh-dev.github.io/uispec/)

---

Made with ❤️ for AI developers