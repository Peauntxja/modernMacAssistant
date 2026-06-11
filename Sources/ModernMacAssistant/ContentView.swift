import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        NavigationSplitView {
            SidebarView()
                .navigationSplitViewColumnWidth(min: 210, ideal: 230, max: 260)
        } detail: {
            ZStack {
                Color(nsColor: .windowBackgroundColor)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        HeaderView(section: appState.selectedSection)

                        switch appState.selectedSection {
                        case .overview:
                            OverviewView()
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
                        case .logs:
                            LogsView()
                        }
                    }
                    .padding(24)
                    .frame(maxWidth: 960, alignment: .leading)
                }
            }
        }
    }
}

private struct SidebarView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        List(AssistantSection.allCases, selection: $appState.selectedSection) { section in
            Label(section.rawValue, systemImage: section.symbol)
                .tag(section)
                .padding(.vertical, 4)
        }
        .navigationTitle("Mac 工具箱")
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
                .font(.system(size: 16, weight: .semibold))
            content
        }
        .padding(18)
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
                .frame(minWidth: 112)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
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
        .controlSize(.large)
    }
}

