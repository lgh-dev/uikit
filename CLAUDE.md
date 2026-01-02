# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

UISpec 是一个纯 Shell 脚本实现的 UI 规范管理系统，专为 AI 编程助手设计。通过简单的命令，让 AI 生成的界面始终保持一致的设计语言。

### 核心特性
- 零依赖，仅需系统自带 bash
- 内置 5 套专业设计规范
- 支持 Claude Code 和 Qoder 集成
- 体积仅 ~15KB

## 常用命令

```bash
# 本地开发测试
./shell/uispec.sh status              # 查看安装状态
./shell/uispec.sh init claude         # 初始化到 Claude Code
./shell/uispec.sh init qoder          # 初始化到 Qoder
./shell/uispec.sh uninstall claude    # 从 Claude Code 卸载

# 安装后全局使用
uispec -h                             # 查看帮助
uispec -v                             # 查看版本
uispec status                         # 查看状态
```

## 代码架构

```
uispec/
├── shell/
│   ├── uispec.sh          # CLI 主入口，分发命令到 commands/
│   ├── commands/
│   │   ├── init.sh       # 初始化命令 (claude/qoder)
│   │   ├── status.sh     # 状态查看
│   │   └── uninstall.sh  # 卸载命令
│   └── lib/
│       ├── colors.sh     # 颜色输出函数
│       ├── config.sh     # 配置管理
│       └── download.sh   # 下载功能
├── specs/                # 设计规范源文件 (5套规范)
├── .uispec/specs/         # 用户项目的规范副本
└── .claude/commands/     # Claude Code slash 命令定义
```

### 设计规范文件格式

每套规范 (如 `dark-elegant.md`) 包含完整的设计系统：
- 色彩系统（背景、文字、边框、功能色各5级层次）
- 字体排版（Inter + JetBrains Mono）
- 间距系统（4px 基数）
- 圆角/阴影/动画系统
- 40+ 组件规范（按钮、输入框、卡片等）

## Claude Code 集成

### /uispec-switch - 切换设计规范

```
/uispec-switch modern-minimal      # 直接切换
/uispec-switch                     # 显示选择列表
```

保存规范名到 `.uispec/current-spec.json`。

### /uispec-do - 按规范开发

**关键要求**：使用 `/uispec-do` 前，必须先读取完整的规范文件全文：

```bash
# ✅ 正确：读取完整规范
Read('.uispec/specs/dark-elegant.md')

# ❌ 错误：使用 limit 参数只读部分
Read('.uispec/specs/dark-elegant.md', limit: 100)
```

然后根据完整规范开发功能，确保遵循色彩、间距、组件样式等所有要求。

### /uispec-check - 审查合规性

按照规范审查代码的：
- 色彩系统
- 间距系统
- 字体排版
- 组件样式
- 响应式设计
- 无障碍要求

## 沟通语言

项目文档和代码注释使用中文，沟通时请使用中文。
