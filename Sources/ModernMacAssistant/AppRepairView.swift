import SwiftUI

struct AppRepairView: View {
    @EnvironmentObject private var appState: AppState
    @State private var selectedApp: URL?
    @State private var useAdmin = false

    var body: some View {
        SectionPanel(title: "应用修复", symbol: "app.badge.checkmark") {
            VStack(alignment: .leading, spacing: 16) {
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
                    PrimaryButton(title: "移除隔离属性", symbol: "shield.slash") {
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
                    SecondaryButton(title: "安装命令行工具", symbol: "terminal") {
                        appState.run("安装 Xcode Command Line Tools") {
                            try await AssistantService.installCommandLineTools()
                        }
                    }
                }
                .disabled(selectedApp == nil)

                Text("重签名需要已安装 Xcode Command Line Tools。移除隔离属性只会处理你选择的应用。")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
            }
        }
    }
}

