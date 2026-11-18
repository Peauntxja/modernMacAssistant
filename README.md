# 现代 Mac 工具箱

一个本地 SwiftUI macOS 小工具，集中保留常用的 macOS 设置和应用修复功能。

## 功能

- 程序坞：位置、图标大小、放大镜、隐藏最近使用、隐藏动画速度、堆栈高亮、滚轮打开堆栈、单应用模式、最小化动画、锁定大小
- 启动台：设置行列数、恢复默认
- 截图：格式、阴影、时间戳、缩略图、文件名前缀、保存位置
- Finder：隐藏文件、路径栏、状态栏、所有扩展名
- 菜单栏：24 小时制、秒、星期、日期、电量百分比
- 应用修复：移除 `com.apple.quarantine`、ad-hoc 重签名、安装 Command Line Tools；刷新 DNS、重建 Spotlight
- 系统信息：macOS、CPU、核心/线程、内存、SIP、硬件和显示摘要
- 日志：在底部折叠区域保留最近执行命令和系统返回

## 构建

```bash
cd /Users/kusuri_mizuki/myProject/ModernMacAssistant
./build-app.sh
```

构建产物：

```text
/Users/kusuri_mizuki/myProject/ModernMacAssistant/build/现代 Mac 工具箱.app
```

## 说明

应用使用原生 SwiftUI 和系统命令实现。需要管理员权限的操作会走 macOS 系统授权弹窗，不使用旧版 `AuthorizationExecuteWithPrivileges`。
