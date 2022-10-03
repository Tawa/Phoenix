import AppVersionProviderContract
import Combine
import Foundation

public struct AppStoreVersionUpdateProvider: AppVersionUpdateProviderProtocol {
    
    public init() {
        
    }
    
    public func appVersionsPublisher() -> AnyPublisher<AppVersions, Error> {
        guard
            let info = Bundle.main.infoDictionary,
            let identifier = info["CFBundleIdentifier"] as? String,
            let url = URL(string: "https://itunes.apple.com/lookup?bundleId=\(identifier)")
        else {
            return Fail(error: AppVersionUpdateError.failedToGetUpdateURL)
                .eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap(\.data)
            .decode(type: AppVersions.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}
