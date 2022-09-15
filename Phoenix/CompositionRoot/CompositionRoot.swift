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
import PBXProjectSyncerContract
import PBXProjectSyncer
import ProjectGeneratorContract
import ProjectGenerator
import RelativeURLProviderContract
import RelativeURLProvider
import DemoAppFeature

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
    
    static let componentPackageProvider = Factory {
        ComponentPackageProvider(
            packageNameProvider: Container.packageNameProvider(),
            packageFolderNameProvider: Container.packageFolderNameProvider(),
            packagePathProvider: Container.packagePathProvider()
        ) as ComponentPackageProviderProtocol
    }
    
    static let componentPackagesProvider = Factory {
        ComponentPackagesProvider(
            componentPackageProvider: Container.componentPackageProvider()
        ) as ComponentPackagesProviderProtocol
    }
    
    static let pbxProjSyncer = Factory {
        PBXProjectSyncer(
            packageFolderNameProvider: Container.packageFolderNameProvider(),
            packageNameProvider: Container.packageNameProvider(),
            packagePathProvider: Container.packagePathProvider(),
            projectWriter: Container.pbxProjectWriter()
        ) as PBXProjectSyncerProtocol
    }
    
    static let pbxProjectWriter = Factory {
        PBXProjectWriter() as PBXProjectWriterProtocol
    }
    
    static let projectGenerator = Factory {
        ProjectGenerator(
            componentPackagesProvider: Container.componentPackagesProvider(),
            packageGenerator: Container.packageGenerator(),
            pbxProjectSyncer: Container.pbxProjSyncer()
        ) as ProjectGeneratorProtocol
    }
    
    static let demoAppNameProvider = Factory {
        DemoAppNameProvider() as DemoAppNameProviderProtocol
    }
    
    static let appVersionUpdateProvider = Factory {
        AppVersionUpdateProvider() as AppVersionUpdateProviderProtocol
    }
    
    static let filesURLDataStore = Factory {
        FilesURLDataStore(
            dictionaryCache: UserDefaults.standard
        ) as FilesURLDataStoreProtocol
    }
}

extension Bundle: CurrentAppVersionStringProviderProtocol {
    public func currentAppVersionString() -> String? {
        infoDictionary?["CFBundleShortVersionString"] as? String
    }
}
