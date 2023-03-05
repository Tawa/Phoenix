import AppVersionProvider
import AppVersionProviderContract
import Factory
import Foundation
import SwiftUI

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
    
    private static let remoteAppVersionUpdateProvider = Factory<AppVersionUpdateProviderProtocol>(Container.shared) {
//        AppStoreVersionUpdateProvider() as AppVersionUpdateProviderProtocol
        GithubVersionUpdateProvider() as AppVersionUpdateProviderProtocol
    }
    
    static let updateButton = Factory(Container.shared) {
        appStoreUpdateButton()
    }
    
    private static let appStoreUpdateButton = Factory(Container.shared) {
        Link(destination: URL(string: "https://apps.apple.com/us/app/phoenix-app/id1626793172")!) {
            Text("Update")
        }
    }
}

extension Bundle: CurrentAppVersionStringProviderProtocol {
    public func currentAppVersionString() -> String? {
        infoDictionary?["CFBundleShortVersionString"] as? String
    }
}
