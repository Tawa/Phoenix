import AppVersionProviderContract
import AppVersionProvider
import DemoAppGeneratorContract
import DemoAppGenerator
import DocumentCoderContract
import DocumentCoder
import Factory
import Foundation
import Package
import PackageGeneratorContract
import PackageGenerator
import PackageStringProviderContract
import PackageStringProvider
import RelativeURLProviderContract
import RelativeURLProvider

extension Container {
    static let currentAppVersionStringProvider = Factory { Bundle.main as CurrentAppVersionStringProviderProtocol }
    static let appVersionStringParser = Factory { AppVersionStringParser() as AppVersionStringParserProtocol }
    static let currentAppVersionProvider = Factory {
        CurrentAppVersionProvider(
            appVersionStringProvider: Container.currentAppVersionStringProvider(),
            appVersionStringParser: Container.appVersionStringParser()
        ) as CurrentAppVersionProviderProtocol
    }

    static let phoenixDocumentFileWrappersDecoder = Factory {
        PhoenixDocumentFileWrappersDecoder(
            appVersionStringParser: Container.appVersionStringParser()
        ) as PhoenixDocumentFileWrappersDecoderProtocol
    }

    static let phoenixDocumentFileWrapperEncoder = Factory {
        PhoenixDocumentFileWrapperEncoder(
            currentAppVersionStringProvider: Container.currentAppVersionStringProvider()
        ) as PhoenixDocumentFileWrapperEncoderProtocol
    }
    
    static let packageGenerator = Factory {
        PackageGenerator(
            fileManager: .default,
            packageStringProvider: Container.packageStringProvider()
        ) as PackageGeneratorProtocol
    }
    
    static let demoAppGenerator = Factory {
        DemoAppGenerator(
            packageNameProvider: PackageNameProvider(),
            packageGenerator: Container.packageGenerator(),
            relativeURLProvider: RelativeURLProvider(),
            fileManager: .default
        ) as DemoAppGeneratorProtocol
    }
    
    static let packageStringProvider = Factory {
        PackageStringProvider() as PackageStringProviding
    }
}

extension Bundle: CurrentAppVersionStringProviderProtocol {
    public func currentAppVersionString() -> String? {
        infoDictionary?["CFBundleShortVersionString"] as? String
    }
}
