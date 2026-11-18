import SwiftUI

struct MenuBarView: View {
    @EnvironmentObject private var appState: AppState
    @State private var settings = MenuBarSettings()

    var body: some View {
        SectionPanel(title: "菜单栏", symbol: "menubar.rectangle") {
            VStack(alignment: .leading, spacing: 12) {
                Grid(alignment: .leading, horizontalSpacing: 18, verticalSpacing: 8) {
                    GridRow {
                        Toggle("24 小时制", isOn: $settings.show24Hour)
                        Toggle("显示秒", isOn: $settings.showSeconds)
                    }
                    GridRow {
                        Toggle("显示星期", isOn: $settings.showDayOfWeek)
                        Toggle("显示日期", isOn: $settings.showDate)
                    }
                    GridRow {
                        Toggle("电量百分比", isOn: $settings.showBatteryPercent)
                        EmptyView()
                    }
                }

                HStack {
                    PrimaryButton(title: "应用", symbol: "checkmark") {
                        appState.run("应用菜单栏设置", {
                            try await AssistantService.updateMenuBar(settings: settings)
                        }, onSuccess: load)
                    }
                    SecondaryButton(title: "恢复默认", symbol: "arrow.counterclockwise") {
                        appState.run("恢复菜单栏默认设置", {
                            try await AssistantService.resetMenuBar()
                        }, onSuccess: load)
                    }
                    SecondaryButton(title: "复制命令", symbol: "doc.on.doc") {
                        AssistantService.copyScript(
                            AssistantService.menuBarApplyScript(settings: settings),
                            title: "复制菜单栏命令",
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
            let loaded = await AssistantService.loadMenuBarSettings()
            await MainActor.run { settings = loaded }
        }
    }
}
