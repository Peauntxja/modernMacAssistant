import SwiftUI
import Foundation

struct SystemInfoView: View {
    @EnvironmentObject private var appState: AppState
    @State private var info: [InfoRow] = []
    @State private var loading = false

    var body: some View {
        SectionPanel(title: "本机信息", symbol: "desktopcomputer") {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    PrimaryButton(title: "刷新", symbol: "arrow.clockwise") {
                        load()
                    }
                    SecondaryButton(title: "复制摘要", symbol: "doc.on.doc") {
                        let summary = info.map { "\($0.title): \($0.value)" }.joined(separator: "\n")
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(summary, forType: .string)
                        appState.append(.init(title: "复制系统摘要", status: .success, detail: "已复制到剪贴板"))
                    }
                }

                Divider()

                if loading {
                    ProgressView()
                } else {
                    Grid(alignment: .leading, horizontalSpacing: 18, verticalSpacing: 10) {
                        ForEach(info) { row in
                            GridRow {
                                Text(row.title)
                                    .foregroundStyle(.secondary)
                                    .frame(width: 78, alignment: .leading)
                                Text(row.value)
                                    .textSelection(.enabled)
                            }
                        }
                    }
                    .font(.system(size: 14))
                }
            }
        }
        .onAppear {
            if info.isEmpty {
                load()
            }
        }
    }

    private func load() {
        loading = true
        Task {
            let rows = await SystemInfoCollector.collect()
            await MainActor.run {
                info = rows
                loading = false
            }
        }
    }
}

struct InfoRow: Identifiable {
    let id = UUID()
    let title: String
    let value: String
}

enum SystemInfoCollector {
    static func collect() async -> [InfoRow] {
        var rows: [InfoRow] = []
        let processInfo = ProcessInfo.processInfo
        let version = processInfo.operatingSystemVersion
        rows.append(.init(title: "macOS", value: "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"))
        rows.append(.init(title: "主机名", value: Host.current().localizedName ?? "未知"))
        rows.append(.init(title: "用户", value: NSUserName()))
        rows.append(.init(title: "CPU", value: sysctlString("machdep.cpu.brand_string")))
        rows.append(.init(title: "核心", value: sysctlInt("machdep.cpu.core_count")))
        rows.append(.init(title: "线程", value: sysctlInt("machdep.cpu.thread_count")))
        rows.append(.init(title: "内存", value: ByteCountFormatter.string(fromByteCount: Int64(processInfo.physicalMemory), countStyle: .memory)))

        async let sip = CommandRunner.run("/usr/bin/csrutil", ["status"])
        async let hardware = CommandRunner.run("/usr/sbin/system_profiler", ["SPHardwareDataType"])
        async let displays = CommandRunner.run("/usr/sbin/system_profiler", ["SPDisplaysDataType"])

        if let sip = try? await sip {
            let text = sip.output.trimmingCharacters(in: .whitespacesAndNewlines)
            if !text.isEmpty {
                rows.append(.init(title: "SIP", value: text))
            }
        }
        if let hardware = try? await hardware,
           let line = firstUsefulLine(from: hardware.output, matching: ["Model Name", "型号名称", "Model Identifier", "机型标识符"]) {
            rows.append(.init(title: "机型", value: line))
        }
        if let displays = try? await displays,
           let line = firstUsefulLine(from: displays.output, matching: ["Chipset Model", "芯片组型号", "Resolution", "分辨率"]) {
            rows.append(.init(title: "显示", value: line))
        }

        return rows
    }

    private static func sysctlString(_ name: String) -> String {
        var size = 0
        guard sysctlbyname(name, nil, &size, nil, 0) == 0, size > 1 else { return "未知" }
        var buffer = [CChar](repeating: 0, count: size)
        guard sysctlbyname(name, &buffer, &size, nil, 0) == 0 else { return "未知" }
        return String(cString: buffer)
    }

    private static func sysctlInt(_ name: String) -> String {
        var value: Int32 = 0
        var size = MemoryLayout<Int32>.size
        guard sysctlbyname(name, &value, &size, nil, 0) == 0 else { return "未知" }
        return "\(value)"
    }

    private static func firstUsefulLine(from text: String, matching keys: [String]) -> String? {
        guard let line = text
            .split(separator: "\n")
            .map({ $0.trimmingCharacters(in: .whitespaces) })
            .first(where: { line in keys.contains { line.contains($0) } }) else { return nil }
        let value = line.split(separator: ":", maxSplits: 1).last.map { $0.trimmingCharacters(in: .whitespaces) } ?? ""
        return value.isEmpty ? line : value
    }
}
