import SwiftUI

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
                }

                HStack {
                    PrimaryButton(title: "应用", symbol: "checkmark") {
                        appState.run("应用截图设置") {
                            try await AssistantService.updateScreenshots(settings: settings)
                        }
                    }
                    SecondaryButton(title: "恢复默认", symbol: "arrow.counterclockwise") {
                        appState.run("恢复截图默认设置") {
                            try await AssistantService.resetScreenshots()
                        }
                    }
                }
            }
        }
    }
}
