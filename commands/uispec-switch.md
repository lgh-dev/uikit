---
description: 选择 UISpec 设计规范
argument-hint: [规范名称: modern-minimal | dark-elegant | creative-playful | professional-business | vibrant-tech]
---

# UISpec Switch - 快速切换设计规范

## 可用规范

1. **modern-minimal** - 现代简约 (SaaS产品、工具应用)
2. **dark-elegant** - 暗黑优雅 (开发IDE、专业软件)
3. **creative-playful** - 创意趣味 (教育产品、创意工具)
4. **professional-business** - 专业商务 (企业应用、金融产品)
5. **vibrant-tech** - 活力科技 (科技产品、游戏平台)

## 使用方式

### 快速切换（推荐）
直接输入命令和规范名：
```
/uispec-switch modern-minimal
/uispec-switch dark-elegant
```

### 或让我帮您选择
如果不带参数运行，我会显示所有规范供您选择：
```
/uispec-switch
```

## 实现逻辑

如果用户提供了参数（$ARGUMENTS）：
1. 直接将该规范名保存到 `.uispec/current-spec.json`
2. 确认切换成功

如果没有提供参数：
1. 显示上面的规范列表
2. 询问用户选择
3. 保存选择到 `.uispec/current-spec.json`

## 配置文件格式
```json
{
  "spec": "规范名称"
}
```