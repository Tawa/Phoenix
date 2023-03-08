import AppVersionProviderContract
import Combine

public struct AppVersionUpdateFilteredProvider: AppVersionUpdateProviderProtocol {
    let appVersionUpdateProvider: AppVersionUpdateProviderProtocol
    let appVersionStringParser: AppVersionStringParserProtocol
    let currentAppVersionProvider: CurrentAppVersionProviderProtocol
    
    public init(appVersionUpdateProvider: AppVersionUpdateProviderProtocol,
                appVersionStringParser: AppVersionStringParserProtocol,
                currentAppVersionProvider: CurrentAppVersionProviderProtocol) {
        self.appVersionUpdateProvider = appVersionUpdateProvider
        self.appVersionStringParser = appVersionStringParser
        self.currentAppVersionProvider = currentAppVersionProvider
    }

    public func appVersionsPublisher() -> AnyPublisher<AppVersions, Error> {
        guard let currentAppVersion = currentAppVersionProvider.currentAppVersion()
        else {
            return Fail(error: AppVersionUpdateError.failedToGetCurrentAppVersion)
                .eraseToAnyPublisher()
        }
        
        return appVersionUpdateProvider
            .appVersionsPublisher()
            .compactMap { appVersions in
                let results = appVersions.results.filter({ appVersionInfo in
                    guard let appVersion = appVersionStringParser.appVersion(from: appVersionInfo.version)
                    else { return false }
                    return currentAppVersion.isOlderThan(version: appVersion)
                })
                
                return AppVersions(results: results)
            }
            .eraseToAnyPublisher()
    }
}
