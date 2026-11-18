import SwiftUI

struct AppRepairView: View {
    @EnvironmentObject private var appState: AppState
    @State private var selectedApp: URL?
    @State private var useAdmin = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionPanel(title: "应用修复", symbol: "app.badge.checkmark") {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(selectedApp?.path ?? "尚未选择应用")
                            .lineLimit(1)
                            .truncationMode(.middle)
                            .foregroundStyle(selectedApp == nil ? .secondary : .primary)
                        Spacer()
                        SecondaryButton(title: "选择应用", symbol: "app") {
                            selectedApp = FilePicker.pickApplication()
                        }
                    }

                    Toggle("使用管理员权限执行", isOn: $useAdmin)

                    HStack {
                        PrimaryButton(title: "去隔离", symbol: "shield.slash") {
                            guard let selectedApp else { return }
                            appState.run("移除隔离属性") {
                                try await AssistantService.removeQuarantine(appURL: selectedApp, asAdmin: useAdmin)
                            }
                        }
                        SecondaryButton(title: "重签名", symbol: "signature") {
                            guard let selectedApp else { return }
                            appState.run("重签名应用") {
                                try await AssistantService.resign(appURL: selectedApp, asAdmin: useAdmin)
                            }
                        }
                    }
                    .disabled(selectedApp == nil)

                    HStack {
                        SecondaryButton(title: "安装命令行工具", symbol: "terminal") {
                            appState.run("安装 Xcode Command Line Tools") {
                                try await AssistantService.installCommandLineTools()
                            }
                        }
                        Text("重签名前需要 Command Line Tools。")
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                    }
                }
            }

            SectionPanel(title: "系统修复", symbol: "wrench.and.screwdriver") {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        PrimaryButton(title: "刷新 DNS", symbol: "network") {
                            appState.run("刷新 DNS") {
                                try await AssistantService.flushDNS()
                            }
                        }
                        SecondaryButton(title: "重建 Spotlight", symbol: "magnifyingglass") {
                            appState.run("重建 Spotlight 索引") {
                                try await AssistantService.rebuildSpotlight()
                            }
                        }
                    }
                    Text("将弹出系统授权；Spotlight 重建可能需一段时间。")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}
