import Foundation

struct CommandResult {
    let executable: String
    let arguments: [String]
    let exitCode: Int32
    let output: String
    let errorOutput: String

    var displayText: String {
        let command = ([executable] + arguments).joined(separator: " ")
        let body = [output, errorOutput]
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .joined(separator: "\n")
        return body.isEmpty ? "\(command)\n退出码: \(exitCode)" : "\(command)\n\n\(body)"
    }
}

enum CommandRunner {
    static func run(_ executable: String, _ arguments: [String] = []) async throws -> CommandResult {
        try await withCheckedThrowingContinuation { continuation in
            do {
                let process = Process()
                let outputPipe = Pipe()
                let errorPipe = Pipe()
                process.executableURL = URL(fileURLWithPath: executable)
                process.arguments = arguments
                process.standardOutput = outputPipe
                process.standardError = errorPipe

                process.terminationHandler = { process in
                    let output = String(data: outputPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
                    let error = String(data: errorPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
                    continuation.resume(returning: CommandResult(
                        executable: executable,
                        arguments: arguments,
                        exitCode: process.terminationStatus,
                        output: output,
                        errorOutput: error
                    ))
                }

                try process.run()
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    static func runShell(_ script: String, asAdmin: Bool = false) async throws -> CommandResult {
        if asAdmin {
            let escaped = script
                .replacingOccurrences(of: "\\", with: "\\\\")
                .replacingOccurrences(of: "\"", with: "\\\"")
            return try await run("/usr/bin/osascript", [
                "-e",
                "do shell script \"\(escaped)\" with administrator privileges"
            ])
        }
        return try await run("/bin/zsh", ["-lc", script])
    }

    static func defaults(_ args: [String]) async throws -> CommandResult {
        try await run("/usr/bin/defaults", args)
    }

    static func killall(_ name: String) async throws -> CommandResult {
        try await run("/usr/bin/killall", [name])
    }
}
