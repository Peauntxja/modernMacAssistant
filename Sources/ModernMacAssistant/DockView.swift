import SwiftUI

struct DockView: View {
    @EnvironmentObject private var appState: AppState
    @State private var settings = DockSettings()

    var body: some View {
        SectionPanel(title: "Dock", symbol: "dock.rectangle") {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("位置")
                        .frame(width: 72, alignment: .leading)
                    Picker("位置", selection: $settings.position) {
                        ForEach(DockPosition.allCases) { position in
                            Text(position.label).tag(position)
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(.segmented)
                    .frame(width: 180)
                }

                HStack {
                    Text("隐藏时长")
                        .frame(width: 72, alignment: .leading)
                    Slider(value: $settings.hideDelay, in: 0...1.2, step: 0.01)
                    Text("\(settings.hideDelay, specifier: "%.2f")s")
                        .monospacedDigit()
                        .frame(width: 58, alignment: .trailing)
                }

                HStack {
                    Text("图标大小")
                        .frame(width: 72, alignment: .leading)
                    Slider(
                        value: Binding(
                            get: { Double(settings.tileSize) },
                            set: { settings.tileSize = Int($0.rounded()) }
                        ),
                        in: 16...128,
                        step: 1
                    )
                    Text("\(settings.tileSize)")
                        .monospacedDigit()
                        .frame(width: 36, alignment: .trailing)
                }

                HStack {
                    Text("放大尺寸")
                        .frame(width: 72, alignment: .leading)
                    Slider(
                        value: Binding(
                            get: { Double(settings.largeSize) },
                            set: { settings.largeSize = Int($0.rounded()) }
                        ),
                        in: 16...128,
                        step: 1
                    )
                    .disabled(!settings.magnification)
                    Text("\(settings.largeSize)")
                        .monospacedDigit()
                        .frame(width: 36, alignment: .trailing)
                }

                Grid(alignment: .leading, horizontalSpacing: 18, verticalSpacing: 8) {
                    GridRow {
                        Toggle("放大镜", isOn: $settings.magnification)
                        Toggle("隐藏最近使用", isOn: $settings.hideRecents)
                    }
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
                        appState.run("应用 Dock 设置", {
                            try await AssistantService.updateDock(settings: settings)
                        }, onSuccess: load)
                    }
                    SecondaryButton(title: "恢复默认", symbol: "arrow.counterclockwise") {
                        appState.run("恢复 Dock 默认设置", {
                            try await AssistantService.resetDock()
                        }, onSuccess: load)
                    }
                    SecondaryButton(title: "复制命令", symbol: "doc.on.doc") {
                        AssistantService.copyScript(
                            AssistantService.dockApplyScript(settings: settings),
                            title: "复制 Dock 命令",
                            into: appState
                        )
                    }
                }
            }
        }
        .onAppear(perform: load)
    }

    private func load() {
        Task {
            let loaded = await AssistantService.loadDockSettings()
            await MainActor.run { settings = loaded }
        }
    }
}
