import AppVersionProviderContract
import Combine
import Foundation

public struct GithubVersionUpdateProvider: AppVersionUpdateProviderProtocol {
    
    public init() {
        
    }
    
    public func appVersionsPublisher() -> AnyPublisher<AppVersions, Error> {
        guard let url = URL(string: "https://api.github.com/repos/Tawa/Phoenix/releases")
        else {
            return Fail(error: AppVersionUpdateError.failedToGetUpdateURL)
                .eraseToAnyPublisher()
        }
        
        return Just(AppVersions(
            results: [
                AppVersionInfo(version: "6.0", releaseNotes: "Release Notes for 6.0"),
                AppVersionInfo(version: "5.0", releaseNotes: "Release Notes for 5.0"),
                AppVersionInfo(version: "4.2.1", releaseNotes: "Release Notes for 4.2.1"),
                AppVersionInfo(version: "4.2", releaseNotes: "Release Notes for 4.2"),
            ])
        )
        .setFailureType(to: Error.self)
        .eraseToAnyPublisher()
        
//        return URLSession.shared.dataTaskPublisher(for: url)
//            .tryMap(\.data)
//            .decode(type: AppVersions.self, decoder: JSONDecoder())
//            .eraseToAnyPublisher()
    }
}
