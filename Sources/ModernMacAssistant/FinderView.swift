import SwiftUI

struct FinderView: View {
    @EnvironmentObject private var appState: AppState
    @State private var settings = FinderSettings()

    var body: some View {
        SectionPanel(title: "Finder", symbol: "folder") {
            VStack(alignment: .leading, spacing: 12) {
                Grid(alignment: .leading, horizontalSpacing: 18, verticalSpacing: 8) {
                    GridRow {
                        Toggle("显示隐藏文件", isOn: $settings.showHiddenFiles)
                        Toggle("显示路径栏", isOn: $settings.showPathBar)
                    }
                    GridRow {
                        Toggle("显示状态栏", isOn: $settings.showStatusBar)
                        Toggle("显示所有扩展名", isOn: $settings.showAllExtensions)
                    }
                }

                HStack {
                    PrimaryButton(title: "应用", symbol: "checkmark") {
                        appState.run("应用 Finder 设置", {
                            try await AssistantService.updateFinder(settings: settings)
                        }, onSuccess: load)
                    }
                    SecondaryButton(title: "恢复默认", symbol: "arrow.counterclockwise") {
                        appState.run("恢复 Finder 默认设置", {
                            try await AssistantService.resetFinder()
                        }, onSuccess: load)
                    }
                    SecondaryButton(title: "复制命令", symbol: "doc.on.doc") {
                        AssistantService.copyScript(
                            AssistantService.finderApplyScript(settings: settings),
                            title: "复制 Finder 命令",
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
            let loaded = await AssistantService.loadFinderSettings()
            await MainActor.run { settings = loaded }
        }
    }
}
