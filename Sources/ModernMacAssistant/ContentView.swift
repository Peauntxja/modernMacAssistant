import SwiftUI
import AppKit

struct ContentView: View {
    @EnvironmentObject private var appState: AppState
    private let compactSections: [AssistantSection] = [.dock, .launchpad, .screenshots, .apps, .system]

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 10) {
                    Image(nsImage: NSApplication.shared.applicationIconImage)
                        .resizable()
                        .frame(width: 28, height: 28)
                    Text("Mac 工具箱")
                        .font(.system(size: 18, weight: .semibold))
                    Spacer()
                    if appState.isRunning {
                        ProgressView()
                            .controlSize(.small)
                    }
                }

                Picker("工具", selection: $appState.selectedSection) {
                    ForEach(compactSections) { section in
                        Label(section.rawValue, systemImage: section.symbol).tag(section)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
            }
            .padding(.horizontal, 18)
            .padding(.top, 14)
            .padding(.bottom, 10)

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    activeTool

                    DisclosureGroup {
                        LogsView()
                    } label: {
                        Label("执行日志", systemImage: "list.bullet.rectangle")
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .padding(.top, 2)
                }
                .padding(16)
            }
        }
        .background(Color(nsColor: .windowBackgroundColor))
    }

    @ViewBuilder
    private var activeTool: some View {
        switch appState.selectedSection {
        case .dock:
            DockView()
        case .launchpad:
            LaunchpadView()
        case .screenshots:
            ScreenshotView()
        case .apps:
            AppRepairView()
        case .system:
            SystemInfoView()
        case .overview:
            DockView()
        case .logs:
            LogsView()
        }
    }
}

private struct HeaderView: View {
    let section: AssistantSection

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(section.rawValue, systemImage: section.symbol)
                .font(.system(size: 28, weight: .semibold))
            Text(subtitle)
                .foregroundStyle(.secondary)
                .font(.system(size: 14))
        }
    }

    private var subtitle: String {
        switch section {
        case .overview:
            "常用 macOS 隐藏设置、应用修复和系统信息集中管理。"
        case .dock:
            "调整程序坞行为，应用后会自动重启 Dock。"
        case .launchpad:
            "修改启动台网格，行列数建议保持 4 到 12。"
        case .screenshots:
            "配置系统截图格式、阴影、缩略图、文件名前缀和保存位置。"
        case .apps:
            "处理应用隔离属性和 ad-hoc 重签名。"
        case .system:
            "读取本机硬件、系统、SIP、CPU 和显示信息。"
        case .logs:
            "查看最近执行的命令和系统返回。"
        }
    }
}

struct SectionPanel<Content: View>: View {
    let title: String
    let symbol: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label(title, systemImage: symbol)
                .font(.system(size: 14, weight: .semibold))
            content
        }
        .padding(14)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

struct PrimaryButton: View {
    let title: String
    let symbol: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: symbol)
                .frame(minWidth: 82)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.regular)
    }
}

struct SecondaryButton: View {
    let title: String
    let symbol: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: symbol)
        }
        .buttonStyle(.bordered)
        .controlSize(.regular)
    }
}
