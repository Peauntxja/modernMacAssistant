import SwiftUI
import AppKit

struct ScreenshotView: View {
    @EnvironmentObject private var appState: AppState
    @State private var settings = ScreenshotSettings()

    var body: some View {
        SectionPanel(title: "截图", symbol: "camera.viewfinder") {
            VStack(alignment: .leading, spacing: 12) {
                Grid(alignment: .leading, horizontalSpacing: 18, verticalSpacing: 8) {
                    GridRow {
                        Toggle("无阴影", isOn: $settings.disableShadow)
                        Toggle("时间戳", isOn: $settings.includeDate)
                        Toggle("缩略图", isOn: $settings.showThumbnail)
                    }
                }

                HStack {
                    Text("前缀")
                        .frame(width: 56, alignment: .leading)
                    TextField("系统默认", text: $settings.filePrefix)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 190)
                }

                HStack {
                    Text("格式")
                        .frame(width: 56, alignment: .leading)
                    Picker("图片格式", selection: $settings.format) {
                        ForEach(ScreenshotFormat.allCases) { format in
                            Text(format.rawValue.uppercased()).tag(format)
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(.segmented)
                    .frame(width: 300)
                }

                HStack {
                    Text("位置")
                        .frame(width: 56, alignment: .leading)
                    Text(settings.saveLocation.path)
                        .lineLimit(1)
                        .truncationMode(.middle)
                        .foregroundStyle(.secondary)
                    Spacer()
                    SecondaryButton(title: "选择", symbol: "folder") {
                        if let url = FilePicker.pickFolder() {
                            settings.saveLocation = url
                        }
                    }
                    SecondaryButton(title: "打开", symbol: "arrow.up.right.square") {
                        NSWorkspace.shared.open(settings.saveLocation)
                        appState.append(.init(title: "打开截图目录", status: .success, detail: settings.saveLocation.path))
                    }
                    SecondaryButton(title: "复制路径", symbol: "doc.on.doc") {
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(settings.saveLocation.path, forType: .string)
                        appState.append(.init(title: "复制截图路径", status: .success, detail: "已复制到剪贴板"))
                    }
                }

                HStack {
                    PrimaryButton(title: "应用", symbol: "checkmark") {
                        appState.run("应用截图设置", {
                            try await AssistantService.updateScreenshots(settings: settings)
                        }, onSuccess: load)
                    }
                    SecondaryButton(title: "恢复默认", symbol: "arrow.counterclockwise") {
                        appState.run("恢复截图默认设置", {
                            try await AssistantService.resetScreenshots()
                        }, onSuccess: load)
                    }
                    SecondaryButton(title: "复制命令", symbol: "doc.on.doc") {
                        AssistantService.copyScript(
                            AssistantService.screenshotsApplyScript(settings: settings),
                            title: "复制截图命令",
                            into: appState
                        )
                    }
                }
            }
        }
        .onAppear(perform: load)
    }

    private func load() {
        Task {
            let loaded = await AssistantService.loadScreenshotSettings()
            await MainActor.run { settings = loaded }
        }
    }
}
