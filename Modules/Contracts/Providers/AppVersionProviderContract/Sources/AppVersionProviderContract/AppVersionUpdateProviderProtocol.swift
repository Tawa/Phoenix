import Combine
import Foundation

// MARK: - AppVersions
public struct AppVersions: Decodable {
    public let results: [AppVersionInfo]
    
    public init(results: [AppVersionInfo]) {
        self.results = results
    }
}

// MARK: - Result
public struct AppVersionInfo: Decodable {
    public let version: String
    public let releaseNotes: String
    
    public init(version: String, releaseNotes: String) {
        self.version = version
        self.releaseNotes = releaseNotes
    }
}

public protocol AppVersionUpdateProviderProtocol {
    func appVersionsPublisher() -> AnyPublisher<AppVersions, Error>
}
