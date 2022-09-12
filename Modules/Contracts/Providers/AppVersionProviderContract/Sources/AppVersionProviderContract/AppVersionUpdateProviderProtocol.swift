import Combine
import Foundation

// MARK: - AppVersions
public struct AppVersions: Decodable {
    public let results: [AppVersionInfo]
}

// MARK: - Result
public struct AppVersionInfo: Decodable {
    public let version: String
    public let releaseNotes: String
}

public protocol AppVersionUpdateProviderProtocol {
    func appVersionsPublisher() -> AnyPublisher<[AppVersionInfo], Error>
}
