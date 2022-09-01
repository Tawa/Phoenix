import AppVersionProviderContract
import AppVersionProvider
import ComponentPackagesProviderContract
import ComponentPackagesProvider
import DemoAppGeneratorContract
import DemoAppGenerator
import DocumentCoderContract
import DocumentCoder
import Factory
import Foundation
import Package
import PackageGeneratorContract
import PackageGenerator
import PackagePathProviderContract
import PackagePathProvider
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
    
    static let familyFolderNameProvider = Factory {
        FamilyFolderNameProvider() as FamilyFolderNameProviding
    }
    
    static let packageNameProvider = Factory {
        PackageNameProvider() as PackageNameProviding
    }
    
    static let packageStringProvider = Factory {
        PackageStringProvider() as PackageStringProviding
    }
    
    static let packageFolderNameProvider = Factory {
        PackageFolderNameProvider(
            defaultFolderNameProvider: Container.familyFolderNameProvider()
        ) as PackageFolderNameProviding
    }
    
    static let packagePathProvider = Factory {
        PackagePathProvider(
            packageFolderNameProvider: Container.packageFolderNameProvider(),
            packageNameProvider: Container.packageNameProvider()
        ) as PackagePathProviding
    }
    
    static let componentPackageProvider = ParameterFactory { (params: String) in
        ComponentPackageProvider(
            packageNameProvider: Container.packageNameProvider(),
            packageFolderNameProvider: Container.packageFolderNameProvider(),
            packagePathProvider: Container.packagePathProvider(),
            swiftVersion: params
        ) as ComponentPackageProviderProtocol
    }
    
    static let componentPackagesProvider = ParameterFactory { (params: String) in
        ComponentPackagesProvider(
            componentPackageProvider: Container.componentPackageProvider(params)
        ) as ComponentPackagesProviderProtocol
    }
}

extension Bundle: CurrentAppVersionStringProviderProtocol {
    public func currentAppVersionString() -> String? {
        infoDictionary?["CFBundleShortVersionString"] as? String
    }
}
