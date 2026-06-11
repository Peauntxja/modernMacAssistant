import SwiftUI

struct ScreenshotView: View {
    @EnvironmentObject private var appState: AppState
    @State private var settings = ScreenshotSettings()

    var body: some View {
        SectionPanel(title: "截图偏好", symbol: "camera.viewfinder") {
            VStack(alignment: .leading, spacing: 16) {
                Toggle("禁用窗口截图阴影", isOn: $settings.disableShadow)
                Toggle("文件名包含时间戳", isOn: $settings.includeDate)
                Toggle("截图后显示缩略图", isOn: $settings.showThumbnail)

                HStack {
                    Text("文件名前缀")
                        .frame(width: 90, alignment: .leading)
                    TextField("留空使用系统默认", text: $settings.filePrefix)
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: 320)
                }

                HStack {
                    Text("图片格式")
                        .frame(width: 90, alignment: .leading)
                    Picker("图片格式", selection: $settings.format) {
                        ForEach(ScreenshotFormat.allCases) { format in
                            Text(format.rawValue.uppercased()).tag(format)
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(.segmented)
                    .frame(width: 330)
                }

                HStack {
                    Text("保存位置")
                        .frame(width: 90, alignment: .leading)
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

