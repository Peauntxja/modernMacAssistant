import SwiftUI

struct OverviewView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 260), spacing: 14)], spacing: 14) {
            ForEach(AssistantSection.allCases.filter { $0 != .overview && $0 != .logs }) { section in
                Button {
                    appState.selectedSection = section
                } label: {
                    VStack(alignment: .leading, spacing: 12) {
                        Image(systemName: section.symbol)
                            .font(.system(size: 24, weight: .medium))
                            .foregroundStyle(.tint)
                        Text(section.rawValue)
                            .font(.system(size: 17, weight: .semibold))
                        Text(description(for: section))
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)
                            .lineLimit(3)
                    }
                    .frame(maxWidth: .infinity, minHeight: 128, alignment: .topLeading)
                    .padding(16)
                    .background(.regularMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }

        SectionPanel(title: "设计说明", symbol: "checklist") {
            VStack(alignment: .leading, spacing: 10) {
                Text("这个版本使用原生 SwiftUI 和系统命令，不依赖 Electron。高风险操作只针对你主动选择的应用路径，执行结果会进入日志页。")
                Text("需要管理员权限时会弹出系统密码授权，不使用旧工具里的废弃管理员执行接口。")
                    .foregroundStyle(.secondary)
            }
            .font(.system(size: 14))
        }
    }

    private func description(for section: AssistantSection) -> String {
        switch section {
        case .dock:
            "隐藏动画速度、堆栈行为、单应用模式和最小化效果。"
        case .launchpad:
            "快速设置启动台网格，或恢复系统默认布局参数。"
        case .screenshots:
            "截图格式、阴影、时间戳、缩略图、保存位置。"
        case .apps:
            "移除 quarantine 隔离属性，或对应用进行 ad-hoc 重签名。"
        case .system:
            "查看 macOS、CPU、内存、显示器、SIP 等信息。"
        default:
            ""
        }
    }
}

