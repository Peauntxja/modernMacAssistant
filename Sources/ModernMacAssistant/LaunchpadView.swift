import SwiftUI

struct LaunchpadView: View {
    static var isAvailable: Bool {
        FileManager.default.fileExists(atPath: "/System/Applications/Launchpad.app")
    }

    @EnvironmentObject private var appState: AppState
    @State private var rows = 6
    @State private var columns = 8

    var body: some View {
        SectionPanel(title: "启动台", symbol: "square.grid.3x3") {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 18) {
                    Stepper(value: $rows, in: 4...12) {
                        Text("行 \(rows)")
                            .monospacedDigit()
                    }
                    Stepper(value: $columns, in: 4...12) {
                        Text("列 \(columns)")
                            .monospacedDigit()
                    }
                }

                HStack {
                    PrimaryButton(title: "应用", symbol: "checkmark") {
                        appState.run("设置启动台网格") {
                            try await AssistantService.setLaunchpad(rows: rows, columns: columns)
                        }
                    }
                    SecondaryButton(title: "恢复默认", symbol: "arrow.counterclockwise") {
                        appState.run("恢复启动台默认设置") {
                            try await AssistantService.resetLaunchpad()
                        }
                    }
                }
            }
        }
    }
}
