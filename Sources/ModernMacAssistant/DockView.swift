import SwiftUI

struct DockView: View {
    @EnvironmentObject private var appState: AppState
    @State private var settings = DockSettings()

    var body: some View {
        SectionPanel(title: "Dock", symbol: "dock.rectangle") {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("隐藏时长")
                        .frame(width: 72, alignment: .leading)
                    Slider(value: $settings.hideDelay, in: 0...1.2, step: 0.01)
                    Text("\(settings.hideDelay, specifier: "%.2f")s")
                        .monospacedDigit()
                        .frame(width: 58, alignment: .trailing)
                }

                Grid(alignment: .leading, horizontalSpacing: 18, verticalSpacing: 8) {
                    GridRow {
                        Toggle("锁定大小", isOn: $settings.lockSize)
                        Toggle("堆栈高亮", isOn: $settings.highlightStacks)
                    }
                    GridRow {
                        Toggle("吮吸动画", isOn: $settings.useSuckEffect)
                        Toggle("单应用模式", isOn: $settings.singleAppMode)
                    }
                    GridRow {
                        Toggle("滚轮打开堆栈", isOn: $settings.scrollToOpen)
                        EmptyView()
                    }
                }

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
