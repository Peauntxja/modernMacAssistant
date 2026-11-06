import Foundation
import SwiftUI

@MainActor
final class AppState: ObservableObject {
    @Published var selectedSection: AssistantSection = .dock
    @Published var logEntries: [LogEntry] = []
    @Published var isRunning = false
    private var inflight = 0

    func run(_ title: String, _ operation: @escaping () async throws -> CommandResult) {
        inflight += 1
        isRunning = true
        let id = UUID()
        append(.init(id: id, title: title, status: .running, detail: "正在执行..."))

        Task {
            let status: LogStatus
            let detail: String
            do {
                let result = try await operation()
                status = result.exitCode == 0 ? .success : .failure
                detail = result.displayText
            } catch {
                status = .failure
                detail = error.localizedDescription
            }
            if let index = logEntries.firstIndex(where: { $0.id == id }) {
                logEntries[index] = .init(id: id, title: title, status: status, detail: detail)
            }
            inflight -= 1
            isRunning = inflight > 0
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
    case dock = "Dock"
    case launchpad = "启动台"
    case screenshots = "截图"
    case apps = "修复"
    case system = "信息"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .dock: "dock.rectangle"
        case .launchpad: "square.grid.3x3"
        case .screenshots: "camera.viewfinder"
        case .apps: "app.badge.checkmark"
        case .system: "desktopcomputer"
        }
    }

    static var tools: [AssistantSection] {
        allCases.filter { $0 != .launchpad || LaunchpadView.isAvailable }
    }
}

struct LogEntry: Identifiable {
    let id: UUID
    let date: Date
    let title: String
    let status: LogStatus
    let detail: String

    init(id: UUID = UUID(), date: Date = Date(), title: String, status: LogStatus, detail: String) {
        self.id = id
        self.date = date
        self.title = title
        self.status = status
        self.detail = detail
    }
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
