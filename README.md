# 现代 Mac 工具箱

一个本地 SwiftUI macOS 工具箱，复刻并现代化了常见 macOS 小助手功能。

## 功能

- 程序坞：隐藏动画速度、堆栈高亮、滚轮打开堆栈、单应用模式、最小化动画、锁定大小
- 启动台：设置行列数、恢复默认
- 截图：格式、阴影、时间戳、缩略图、文件名前缀、保存位置
- 应用修复：移除 `com.apple.quarantine`、ad-hoc 重签名、安装 Command Line Tools
- 系统信息：macOS、CPU、核心/线程、内存、SIP、硬件和显示摘要
- 日志：保留最近执行命令和系统返回

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
