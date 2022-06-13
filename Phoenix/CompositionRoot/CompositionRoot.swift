import Foundation
import AppVersionProviderContract
import AppVersionProvider
import DocumentCoderContract
import DocumentCoder
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

        register { resolver in
            PhoenixDocumentFileWrappersDecoder(
                appVersionStringParser: resolver.resolve()
            )
        }.implements(PhoenixDocumentFileWrappersDecoderProtocol.self)

        register { resolver in
            PhoenixDocumentFileWrapperEncoder(
                currentApp: resolver.resolve()
            )
        }.implements(PhoenixDocumentFileWrapperEncoderProtocol.self)
    }
}
