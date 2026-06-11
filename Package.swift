// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "ModernMacAssistant",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "ModernMacAssistant", targets: ["ModernMacAssistant"])
    ],
    targets: [
        .executableTarget(
            name: "ModernMacAssistant",
            path: "Sources/ModernMacAssistant"
        )
    ]
)
