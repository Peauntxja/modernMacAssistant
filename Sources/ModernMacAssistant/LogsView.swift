import SwiftUI

struct LogsView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        SectionPanel(title: "执行日志", symbol: "list.bullet.rectangle") {
            if appState.logEntries.isEmpty {
                ContentUnavailableView("暂无日志", systemImage: "tray", description: Text("执行操作后会显示命令结果。"))
            } else {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(appState.logEntries) { entry in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: entry.status.symbol)
                                    .foregroundStyle(entry.status.color)
                                Text(entry.title)
                                    .font(.system(size: 14, weight: .semibold))
                                Spacer()
                                Text(entry.date, style: .time)
                                    .foregroundStyle(.secondary)
                                    .font(.system(size: 12))
                            }
                            Text(entry.detail)
                                .font(.system(size: 12, design: .monospaced))
                                .textSelection(.enabled)
                                .foregroundStyle(.secondary)
                                .lineLimit(12)
                        }
                        .padding(12)
                        .background(Color(nsColor: .controlBackgroundColor))
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }
                }
            }
        }
    }
}

