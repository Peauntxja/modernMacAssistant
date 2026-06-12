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

        if let sip = try? await CommandRunner.run("/usr/bin/csrutil", ["status"]) {
            rows.append(.init(title: "SIP", value: sip.output.trimmingCharacters(in: .whitespacesAndNewlines)))
        }

        if let hardware = try? await CommandRunner.run("/usr/sbin/system_profiler", ["SPHardwareDataType"]) {
            rows.append(.init(title: "硬件摘要", value: firstUsefulLine(from: hardware.output, matching: ["Model Name", "Model Identifier"]) ?? "已读取"))
        }

        if let displays = try? await CommandRunner.run("/usr/sbin/system_profiler", ["SPDisplaysDataType"]) {
            rows.append(.init(title: "显示/GPU", value: firstUsefulLine(from: displays.output, matching: ["Chipset Model", "Display Type", "Resolution"]) ?? "已读取"))
        }

        return rows
    }

    private static func sysctlString(_ name: String) -> String {
        var size = 0
        sysctlbyname(name, nil, &size, nil, 0)
        var buffer = [CChar](repeating: 0, count: size)
        sysctlbyname(name, &buffer, &size, nil, 0)
        return String(cString: buffer)
    }

    private static func sysctlInt(_ name: String) -> String {
        var value: Int32 = 0
        var size = MemoryLayout<Int32>.size
        sysctlbyname(name, &value, &size, nil, 0)
        return "\(value)"
    }

    private static func firstUsefulLine(from text: String, matching keys: [String]) -> String? {
        text
            .split(separator: "\n")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .first { line in keys.contains { line.contains($0) } }
    }
}
