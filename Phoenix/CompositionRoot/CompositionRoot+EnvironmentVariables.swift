import Factory
import Foundation

extension Container {
    static let isGithubRelease: Bool = {
        ProcessInfo.processInfo.environment["release_destination"] == "github"
    }()
}
