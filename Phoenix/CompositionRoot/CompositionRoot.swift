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
import PBXProjectSyncerContract
import PBXProjectSyncer

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
            packageGenerator: Container.packageGenerator(),
            packageNameProvider: PackageNameProvider(),
            packagePathProvider: Container.packagePathProvider(),
            relativeURLProvider: RelativeURLProvider(),
            fileManager: .default
        ) as DemoAppGeneratorProtocol
    }
    
    static let familyFolderNameProvider = Factory {
        FamilyFolderNameProvider() as FamilyFolderNameProviderProtocol
    }
    
    static let packageNameProvider = Factory {
        PackageNameProvider() as PackageNameProviderProtocol
    }
    
    static let packageStringProvider = Factory {
        PackageStringProvider() as PackageStringProviderProtocol
    }
    
    static let packageFolderNameProvider = Factory {
        PackageFolderNameProvider(
            defaultFolderNameProvider: Container.familyFolderNameProvider()
        ) as PackageFolderNameProviderProtocol
    }
    
    static let packagePathProvider = Factory {
        PackagePathProvider(
            packageFolderNameProvider: Container.packageFolderNameProvider(),
            packageNameProvider: Container.packageNameProvider()
        ) as PackagePathProviderProtocol
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
    
    static let pbxProjSyncer = Factory {
        PBXProjectSyncer() as PBXProjectSyncerProtocol
    }
}

extension Bundle: CurrentAppVersionStringProviderProtocol {
    public func currentAppVersionString() -> String? {
        infoDictionary?["CFBundleShortVersionString"] as? String
    }
}
