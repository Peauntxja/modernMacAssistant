import SwiftUI

struct LogsView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if appState.logEntries.isEmpty {
                Text("暂无执行记录")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                ForEach(appState.logEntries.prefix(8)) { entry in
                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                            Image(systemName: entry.status.symbol)
                                .foregroundStyle(entry.status.color)
                            Text(entry.title)
                                .font(.system(size: 12, weight: .semibold))
                            Spacer()
                            Text(entry.date, style: .time)
                                .foregroundStyle(.secondary)
                                .font(.system(size: 11))
                        }
                        Text(entry.detail)
                            .font(.system(size: 11, design: .monospaced))
                            .textSelection(.enabled)
                            .foregroundStyle(.secondary)
                            .lineLimit(5)
                    }
                    .padding(10)
                    .background(Color(nsColor: .controlBackgroundColor))
                    .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
                }
            }
        }
    }
}
