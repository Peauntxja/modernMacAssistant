import Foundation
import SwiftUI

@MainActor
final class AppState: ObservableObject {
    @Published var selectedSection: AssistantSection = .overview
    @Published var logEntries: [LogEntry] = []
    @Published var isRunning = false

    func run(_ title: String, _ operation: @escaping () async throws -> CommandResult) {
        isRunning = true
        append(.init(title: title, status: .running, detail: "正在执行..."))

        Task {
            do {
                let result = try await operation()
                await MainActor.run {
                    self.append(.init(
                        title: title,
                        status: result.exitCode == 0 ? .success : .failure,
                        detail: result.displayText
                    ))
                    self.isRunning = false
                }
            } catch {
                await MainActor.run {
                    self.append(.init(title: title, status: .failure, detail: error.localizedDescription))
                    self.isRunning = false
                }
            }
        }
    }

    func append(_ entry: LogEntry) {
        logEntries.insert(entry, at: 0)
        if logEntries.count > 80 {
            logEntries.removeLast(logEntries.count - 80)
        }
    }
}

enum AssistantSection: String, CaseIterable, Identifiable {
    case overview = "概览"
    case dock = "程序坞"
    case launchpad = "启动台"
    case screenshots = "截图"
    case apps = "应用修复"
    case system = "系统信息"
    case logs = "日志"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .overview: "sparkles"
        case .dock: "dock.rectangle"
        case .launchpad: "square.grid.3x3"
        case .screenshots: "camera.viewfinder"
        case .apps: "app.badge.checkmark"
        case .system: "desktopcomputer"
        case .logs: "list.bullet.rectangle"
        }
    }
}

struct LogEntry: Identifiable {
    let id = UUID()
    let date = Date()
    let title: String
    let status: LogStatus
    let detail: String
}

enum LogStatus {
    case running
    case success
    case failure

    var symbol: String {
        switch self {
        case .running: "clock"
        case .success: "checkmark.circle.fill"
        case .failure: "xmark.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .running: .secondary
        case .success: .green
        case .failure: .red
        }
    }
}

