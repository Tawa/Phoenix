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
        guard
            let info = Bundle.main.infoDictionary,
            let currentVersionString = info["CFBundleShortVersionString"] as? String,
            let identifier = info["CFBundleIdentifier"] as? String,
            let url = URL(string: "https://itunes.apple.com/lookup?bundleId=\(identifier)")
        else {
            return Fail(error: AppVersionUpdateError.couldNotLoad)
                .eraseToAnyPublisher()
        }
        
        let appVersionParser = AppVersionStringParser()
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap(\.data)
            .decode(type: AppVersions.self, decoder: JSONDecoder())
            .compactMap { $0.results }
            .eraseToAnyPublisher()
    }
}

