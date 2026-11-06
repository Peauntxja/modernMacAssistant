import SwiftUI
import AppKit

struct ContentView: View {
    @EnvironmentObject private var appState: AppState
    private var compactSections: [AssistantSection] { AssistantSection.tools }

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
