import AppVersionProviderContract
import Combine
import Foundation

public struct AppVersionUpdateProvider: AppVersionUpdateProviderProtocol {
    enum AppVersionUpdateError: Error {
        case notImplemented
        case couldNotLoad
    }

    public init() {
        
    }
    
    public func appVersionsPublisher() -> AnyPublisher<[AppVersionInfo], Error> {
        let appVersionParser = AppVersionStringParser()
        
        guard
            let info = Bundle.main.infoDictionary,
            let currentVersionString = info["CFBundleShortVersionString"] as? String,
            let currentVersion = appVersionParser.appVersion(from: currentVersionString),
            let identifier = info["CFBundleIdentifier"] as? String,
            let url = URL(string: "https://itunes.apple.com/lookup?bundleId=\(identifier)")
        else {
            return Fail(error: AppVersionUpdateError.couldNotLoad)
                .eraseToAnyPublisher()
        }
        
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap(\.data)
            .decode(type: AppVersions.self, decoder: JSONDecoder())
            .compactMap { $0.results.filter { version in
                guard let version = appVersionParser.appVersion(from: version.version)
                else { return false }
                return currentVersion.isOlderThan(version: version)
            }}
            .eraseToAnyPublisher()
    }
}

