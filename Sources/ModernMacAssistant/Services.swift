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

    static func setLaunchpad(rows: Int, columns: Int) async throws -> CommandResult {
        try await CommandRunner.runShell("""
        /usr/bin/defaults write com.apple.dock springboard-rows -int \(rows)
        /usr/bin/defaults write com.apple.dock springboard-columns -int \(columns)
        /usr/bin/killall Dock || true
        """)
    }

    static func resetDock() async throws -> CommandResult {
        try await CommandRunner.runShell("""
        for key in autohide-time-modifier mineffect scroll-to-open single-app mouse-over-hilite-stack size-immutable; do
          /usr/bin/defaults delete com.apple.dock "$key" 2>/dev/null || true
        done
        /usr/bin/killall Dock || true
        """)
    }

    static func updateDock(settings: DockSettings) async throws -> CommandResult {
        let effect = settings.useSuckEffect ? "suck" : "genie"
        return try await CommandRunner.runShell("""
        /usr/bin/defaults write com.apple.dock autohide-time-modifier -float \(settings.hideDelay)
        /usr/bin/defaults write com.apple.dock mineffect -string \(effect)
        /usr/bin/defaults write com.apple.dock scroll-to-open -bool \(settings.scrollToOpen)
        /usr/bin/defaults write com.apple.dock single-app -bool \(settings.singleAppMode)
        /usr/bin/defaults write com.apple.dock mouse-over-hilite-stack -bool \(settings.highlightStacks)
        /usr/bin/defaults write com.apple.dock size-immutable -bool \(settings.lockSize)
        /usr/bin/killall Dock || true
        """)
    }

    static func resetScreenshots() async throws -> CommandResult {
        try await CommandRunner.runShell("""
        for key in disable-shadow include-date show-thumbnail name location type; do
          /usr/bin/defaults delete com.apple.screencapture "$key" 2>/dev/null || true
        done
        /usr/bin/killall SystemUIServer || true
        """)
    }

    static func updateScreenshots(settings: ScreenshotSettings) async throws -> CommandResult {
        let name = settings.filePrefix.trimmingCharacters(in: .whitespacesAndNewlines)
        let nameLine = name.isEmpty
            ? "/usr/bin/defaults delete com.apple.screencapture name 2>/dev/null || true"
            : "/usr/bin/defaults write com.apple.screencapture name -string \(shellQuote(name))"
        let location = settings.saveLocation.path
        return try await CommandRunner.runShell("""
        /usr/bin/defaults write com.apple.screencapture disable-shadow -bool \(settings.disableShadow)
        /usr/bin/defaults write com.apple.screencapture include-date -bool \(settings.includeDate)
        /usr/bin/defaults write com.apple.screencapture show-thumbnail -bool \(settings.showThumbnail)
        /usr/bin/defaults write com.apple.screencapture type -string \(shellQuote(settings.format.rawValue))
        \(nameLine)
        /usr/bin/defaults write com.apple.screencapture location -string \(shellQuote(location))
        /usr/bin/killall SystemUIServer || true
        """)
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
