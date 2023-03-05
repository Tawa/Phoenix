import AppVersionProvider
import AppVersionProviderContract
import Factory
import Foundation

extension Container {
    static let currentAppVersionStringProvider = Factory(Container.shared) {
        Bundle.main as CurrentAppVersionStringProviderProtocol
    }
    
    static let appVersionStringParser = Factory(Container.shared) {
        AppVersionStringParser() as AppVersionStringParserProtocol
    }
    
    static let currentAppVersionProvider = Factory(Container.shared) {
        CurrentAppVersionProvider(
            appVersionStringProvider: Container.currentAppVersionStringProvider(),
            appVersionStringParser: Container.appVersionStringParser()
        ) as CurrentAppVersionProviderProtocol
    }
    
    static let appVersionUpdateProvider = Factory(Container.shared) {
        AppVersionUpdateFilteredProvider(
            appVersionUpdateProvider: Container.remoteAppVersionUpdateProvider(),
            appVersionStringParser: Container.appVersionStringParser(),
            currentAppVersionProvider: Container.currentAppVersionProvider()
        ) as AppVersionUpdateProviderProtocol
    }
    
    static let remoteAppVersionUpdateProvider = Factory(Container.shared) {
        AppStoreVersionUpdateProvider() as AppVersionUpdateProviderProtocol
    }
}

extension Bundle: CurrentAppVersionStringProviderProtocol {
    public func currentAppVersionString() -> String? {
        infoDictionary?["CFBundleShortVersionString"] as? String
    }
}
