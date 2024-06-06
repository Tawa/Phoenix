import Foundation

enum Console {
    @MainActor
    private static var lastLevel = 0

    @MainActor
    static func print(level: Int = 0, _ icon: ConsoleIcon? = nil, _ content: String..., terminator: String = "\n") {
        defer { lastLevel = level }

        if level < lastLevel || level == 0 {
            Swift.print()
        }

        var prefix = ""

        if !content.isEmpty {
            prefix = Array(repeating: " ", count: level * 4).joined()
            prefix += (level == 0) ? "▹" : "-"
        }

        let messageComponents = [icon?.description] + content

        let message = messageComponents.compactMap({ $0 }).joined(separator: "  ")

        if prefix.isEmpty {
            Swift.print(message, terminator: terminator)
        } else {
            Swift.print(prefix, message, terminator: terminator)
        }
    }
}

enum ConsoleIcon: String, CustomStringConvertible, Sendable {
    case cleanFile = "☑️"
    case computer = "💻"
    case dryRun = "🎯"
    case error = "❌"
    case exitSuccess = "🤙🏽"
    case fileSave = "💾"
    case folder = "📁"
    case search = "🔎"
    case visit = "🏃‍♀️‍➡️"
    case updatedFile = "✅"
    case warning = "🔸"

    var description: String { rawValue }
}
