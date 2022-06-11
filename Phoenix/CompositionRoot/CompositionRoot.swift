import Foundation
import AppVersionProviderContract
import AppVersionProvider

import Resolver

extension Bundle: CurrentAppVersionStringProviderProtocol {
    public func currentAppVersionString() -> String? {
        infoDictionary?["CFBundleShortVersionString"] as? String
    }
}

extension Resolver: ResolverRegistering {
    public static func registerAllServices() {
        register {
            Bundle.main
        }.implements(CurrentAppVersionStringProviderProtocol.self)

        register {
            AppVersionStringParser()
        }.implements(AppVersionStringParserProtocol.self)

        register {
            CurrentAppVersionProvider(appVersionStringProvider: resolve(),
                                      appVersionStringParser: resolve())
        }.implements(CurrentAppVersionProviderProtocol.self)
    }
}
