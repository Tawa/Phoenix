import Factory
import Foundation

extension Container {
    static let isGitHubRelease: Bool = {
        ProcessInfo.processInfo.environment["release_destination"] == "github"
    }()
}
