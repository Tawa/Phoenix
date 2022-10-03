import AppVersionProvider
import AppVersionProviderContract
import Factory
import Foundation

extension Container {
    static let currentAppVersionStringProvider = Factory { Bundle.main as CurrentAppVersionStringProviderProtocol }
    
    static let appVersionStringParser = Factory { AppVersionStringParser() as AppVersionStringParserProtocol }
    
    static let currentAppVersionProvider = Factory {
        CurrentAppVersionProvider(
            appVersionStringProvider: Container.currentAppVersionStringProvider(),
            appVersionStringParser: Container.appVersionStringParser()
        ) as CurrentAppVersionProviderProtocol
    }
    
    static let appVersionUpdateProvider = Factory {
        AppVersionUpdateFilteredProvider(
            appVersionUpdateProvider: Container.removeAppVersionUpdateProvider(),
            appVersionStringParser: Container.appVersionStringParser(),
            currentAppVersionProvider: Container.currentAppVersionProvider()
        ) as AppVersionUpdateProviderProtocol
    }
    
    static let removeAppVersionUpdateProvider = Factory {
        AppStoreVersionUpdateProvider() as AppVersionUpdateProviderProtocol
    }
}

extension Bundle: CurrentAppVersionStringProviderProtocol {
    public func currentAppVersionString() -> String? {
        infoDictionary?["CFBundleShortVersionString"] as? String
    }
}
