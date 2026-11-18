import Foundation
import AppKit
import UniformTypeIdentifiers

enum AssistantService {
    private static func shellQuote(_ value: String) -> String {
        "'" + value.replacingOccurrences(of: "'", with: "'\\''") + "'"
    }

    static func resetLaunchpad() async throws -> CommandResult {
        try await CommandRunner.runShell("""
        /usr/bin/defaults delete com.apple.dock springboard-rows 2>/dev/null || true
        /usr/bin/defaults delete com.apple.dock springboard-columns 2>/dev/null || true
        /usr/bin/killall Dock || true
        """)
    }

    static func launchpadApplyScript(rows: Int, columns: Int) -> String {
        """
        /usr/bin/defaults write com.apple.dock springboard-rows -int \(rows)
        /usr/bin/defaults write com.apple.dock springboard-columns -int \(columns)
        /usr/bin/killall Dock || true
        """
    }

    static func setLaunchpad(rows: Int, columns: Int) async throws -> CommandResult {
        try await CommandRunner.runShell(launchpadApplyScript(rows: rows, columns: columns))
    }

    static func resetDock() async throws -> CommandResult {
        try await CommandRunner.runShell("""
        for key in autohide-time-modifier mineffect scroll-to-open single-app mouse-over-hilite-stack size-immutable; do
          /usr/bin/defaults delete com.apple.dock "$key" 2>/dev/null || true
        done
        /usr/bin/killall Dock || true
        """)
    }

    static func dockApplyScript(settings: DockSettings) -> String {
        let effect = settings.useSuckEffect ? "suck" : "genie"
        return """
        /usr/bin/defaults write com.apple.dock autohide-time-modifier -float \(settings.hideDelay)
        /usr/bin/defaults write com.apple.dock mineffect -string \(effect)
        /usr/bin/defaults write com.apple.dock scroll-to-open -bool \(settings.scrollToOpen)
        /usr/bin/defaults write com.apple.dock single-app -bool \(settings.singleAppMode)
        /usr/bin/defaults write com.apple.dock mouse-over-hilite-stack -bool \(settings.highlightStacks)
        /usr/bin/defaults write com.apple.dock size-immutable -bool \(settings.lockSize)
        /usr/bin/killall Dock || true
        """
    }

    static func updateDock(settings: DockSettings) async throws -> CommandResult {
        try await CommandRunner.runShell(dockApplyScript(settings: settings))
    }

    static func resetScreenshots() async throws -> CommandResult {
        try await CommandRunner.runShell("""
        for key in disable-shadow include-date show-thumbnail name location type; do
          /usr/bin/defaults delete com.apple.screencapture "$key" 2>/dev/null || true
        done
        /usr/bin/killall SystemUIServer || true
        """)
    }

    static func screenshotsApplyScript(settings: ScreenshotSettings) -> String {
        let name = settings.filePrefix.trimmingCharacters(in: .whitespacesAndNewlines)
        let nameLine = name.isEmpty
            ? "/usr/bin/defaults delete com.apple.screencapture name 2>/dev/null || true"
            : "/usr/bin/defaults write com.apple.screencapture name -string \(shellQuote(name))"
        let location = settings.saveLocation.path
        return """
        /usr/bin/defaults write com.apple.screencapture disable-shadow -bool \(settings.disableShadow)
        /usr/bin/defaults write com.apple.screencapture include-date -bool \(settings.includeDate)
        /usr/bin/defaults write com.apple.screencapture show-thumbnail -bool \(settings.showThumbnail)
        /usr/bin/defaults write com.apple.screencapture type -string \(shellQuote(settings.format.rawValue))
        \(nameLine)
        /usr/bin/defaults write com.apple.screencapture location -string \(shellQuote(location))
        /usr/bin/killall SystemUIServer || true
        """
    }

    static func updateScreenshots(settings: ScreenshotSettings) async throws -> CommandResult {
        try await CommandRunner.runShell(screenshotsApplyScript(settings: settings))
    }









    @MainActor
    static func copyScript(_ script: String, title: String, into appState: AppState) {
        let text = script.trimmingCharacters(in: .whitespacesAndNewlines)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
        appState.append(.init(title: title, status: .success, detail: "已复制到剪贴板"))
    }

    static func removeQuarantine(appURL: URL, asAdmin: Bool) async throws -> CommandResult {
        try await CommandRunner.runShell("/usr/bin/xattr -dr com.apple.quarantine \(shellQuote(appURL.path))", asAdmin: asAdmin)
    }

    static func resign(appURL: URL, asAdmin: Bool) async throws -> CommandResult {
        try await CommandRunner.runShell("/usr/bin/codesign --force --deep --sign - \(shellQuote(appURL.path))", asAdmin: asAdmin)
    }

    static func installCommandLineTools() async throws -> CommandResult {
        try await CommandRunner.run("/usr/bin/xcode-select", ["--install"])
    }



    static func loadDockSettings() async -> DockSettings {
        var settings = DockSettings()
        if let value = await readDouble(domain: "com.apple.dock", key: "autohide-time-modifier") {
            settings.hideDelay = min(max(value, 0), 1.2)
        }
        if let value = await readBool(domain: "com.apple.dock", key: "size-immutable") {
            settings.lockSize = value
        }
        if let value = await readBool(domain: "com.apple.dock", key: "mouse-over-hilite-stack") {
            settings.highlightStacks = value
        }
        if let value = await readString(domain: "com.apple.dock", key: "mineffect") {
            settings.useSuckEffect = value == "suck"
        }
        if let value = await readBool(domain: "com.apple.dock", key: "single-app") {
            settings.singleAppMode = value
        }
        if let value = await readBool(domain: "com.apple.dock", key: "scroll-to-open") {
            settings.scrollToOpen = value
        }
        return settings
    }

    static func loadLaunchpadGrid() async -> (rows: Int, columns: Int) {
        var rows = 6
        var columns = 8
        if let value = await readInt(domain: "com.apple.dock", key: "springboard-rows") {
            rows = min(max(value, 4), 12)
        }
        if let value = await readInt(domain: "com.apple.dock", key: "springboard-columns") {
            columns = min(max(value, 4), 12)
        }
        return (rows, columns)
    }

    static func loadScreenshotSettings() async -> ScreenshotSettings {
        var settings = ScreenshotSettings()
        if let value = await readBool(domain: "com.apple.screencapture", key: "disable-shadow") {
            settings.disableShadow = value
        }
        if let value = await readBool(domain: "com.apple.screencapture", key: "include-date") {
            settings.includeDate = value
        }
        if let value = await readBool(domain: "com.apple.screencapture", key: "show-thumbnail") {
            settings.showThumbnail = value
        }
        if let value = await readString(domain: "com.apple.screencapture", key: "name") {
            settings.filePrefix = value
        }
        if let value = await readString(domain: "com.apple.screencapture", key: "location"), !value.isEmpty {
            settings.saveLocation = URL(fileURLWithPath: value)
        }
        if let value = await readString(domain: "com.apple.screencapture", key: "type"),
           let format = ScreenshotFormat(rawValue: value.lowercased()) {
            settings.format = format
        }
        return settings
    }

    private static func readRaw(domain: String, key: String, currentHost: Bool = false) async -> String? {
        var arguments = ["read", domain, key]
        if currentHost {
            arguments = ["-currentHost", "read", domain, key]
        }
        guard let result = try? await CommandRunner.run("/usr/bin/defaults", arguments),
              result.exitCode == 0 else { return nil }
        let text = result.output.trimmingCharacters(in: .whitespacesAndNewlines)
        return text.isEmpty ? nil : text
    }

    private static func readBool(domain: String, key: String, currentHost: Bool = false) async -> Bool? {
        guard let text = await readRaw(domain: domain, key: key, currentHost: currentHost)?.lowercased() else { return nil }
        if ["1", "true", "yes"].contains(text) { return true }
        if ["0", "false", "no"].contains(text) { return false }
        return nil
    }

    private static func readInt(domain: String, key: String, currentHost: Bool = false) async -> Int? {
        guard let text = await readRaw(domain: domain, key: key, currentHost: currentHost) else { return nil }
        return Int(text)
    }

    private static func readDouble(domain: String, key: String) async -> Double? {
        guard let text = await readRaw(domain: domain, key: key) else { return nil }
        return Double(text)
    }

    private static func readString(domain: String, key: String) async -> String? {
        await readRaw(domain: domain, key: key)
    }
}

struct DockSettings {
    var hideDelay = 0.18
    var lockSize = false
    var highlightStacks = true
    var useSuckEffect = false
    var singleAppMode = false
    var scrollToOpen = true
}

struct ScreenshotSettings {
    var disableShadow = false
    var includeDate = true
    var showThumbnail = true
    var filePrefix = "截屏"
    var saveLocation = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first ?? URL(fileURLWithPath: NSHomeDirectory())
    var format: ScreenshotFormat = .png
}

enum ScreenshotFormat: String, CaseIterable, Identifiable {
    case png
    case jpg
    case heic
    case pdf
    case tiff

    var id: String { rawValue }
}

enum FilePicker {
    static func pickApplication() -> URL? {
        let panel = NSOpenPanel()
        panel.title = "选择应用程序"
        panel.allowedContentTypes = [.application]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        return panel.runModal() == .OK ? panel.url : nil
    }

    static func pickFolder() -> URL? {
        let panel = NSOpenPanel()
        panel.title = "选择文件夹"
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        return panel.runModal() == .OK ? panel.url : nil
    }
}
