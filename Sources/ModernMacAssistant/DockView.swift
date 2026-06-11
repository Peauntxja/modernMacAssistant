import SwiftUI

struct DockView: View {
    @EnvironmentObject private var appState: AppState
    @State private var settings = DockSettings()

    var body: some View {
        SectionPanel(title: "程序坞行为", symbol: "dock.rectangle") {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("显示/隐藏动画速度")
                    Slider(value: $settings.hideDelay, in: 0...1.2, step: 0.01)
                    Text("\(settings.hideDelay, specifier: "%.2f")s")
                        .monospacedDigit()
                        .frame(width: 58, alignment: .trailing)
                }

                Toggle("禁止调节程序坞大小", isOn: $settings.lockSize)
                Toggle("鼠标滑过堆栈时高亮", isOn: $settings.highlightStacks)
                Toggle("使用隐藏的吮吸最小化动画", isOn: $settings.useSuckEffect)
                Toggle("启用单应用程序模式", isOn: $settings.singleAppMode)
                Toggle("用鼠标滚轮打开堆栈", isOn: $settings.scrollToOpen)

                HStack {
                    PrimaryButton(title: "应用", symbol: "checkmark") {
                        appState.run("应用 Dock 设置") {
                            try await AssistantService.updateDock(settings: settings)
                        }
                    }
                    SecondaryButton(title: "恢复默认", symbol: "arrow.counterclockwise") {
                        appState.run("恢复 Dock 默认设置") {
                            try await AssistantService.resetDock()
                        }
                    }
                }
            }
        }
    }
}

