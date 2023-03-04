import ComponentDetailsProvider
import ComponentDetailsProviderContract
import DemoAppFeature
import DemoAppGenerator
import DemoAppGeneratorContract
import DocumentCoder
import DocumentCoderContract
import Factory
import Foundation
import GenerateFeatureDataStore
import GenerateFeatureDataStoreContract
import PackageGenerator
import PackageGeneratorContract
import PackageStringProvider
import PackageStringProviderContract
import PBXProjectSyncer
import PBXProjectSyncerContract
import ProjectGenerator
import ProjectGeneratorContract
import ProjectValidator
import ProjectValidatorContract
import RelativeURLProvider
import RelativeURLProviderContract
import SwiftPackage

extension Container {
    static let phoenixDocumentFileWrappersDecoder = Factory {
        PhoenixDocumentFileWrappersDecoder() as PhoenixDocumentFileWrappersDecoderProtocol
    }

    static let phoenixDocumentFileWrapperEncoder = Factory {
        PhoenixDocumentFileWrapperEncoder(
            currentAppVersionStringProvider: currentAppVersionStringProvider()
        ) as PhoenixDocumentFileWrapperEncoderProtocol
    }
    
    static let packageGenerator = Factory {
        PackageGenerator(
            fileManager: .default,
            packageStringProvider: packageStringProvider()
        ) as PackageGeneratorProtocol
    }
    
    static let demoAppGenerator = Factory {
        DemoAppGenerator(
            fileManager: FileManager.default
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
            defaultFolderNameProvider: familyFolderNameProvider()
        ) as PackageFolderNameProviderProtocol
    }
    
    static let packagePathProvider = Factory {
        PackagePathProvider(
            packageFolderNameProvider: packageFolderNameProvider(),
            packageNameProvider: packageNameProvider()
        ) as PackagePathProviderProtocol
    }
    
    static let componentPackageProvider = Factory {
        ComponentPackageProvider(
            packageFolderNameProvider: packageFolderNameProvider(),
            packageNameProvider: packageNameProvider(),
            packagePathProvider: packagePathProvider()
        ) as ComponentPackageProviderProtocol
    }
    
    static let componentPackagesProvider = Factory {
        ComponentPackagesProvider(
            componentPackageProvider: componentPackageProvider()
        ) as ComponentPackagesProviderProtocol
    }
    
    static let documentPackagesProvider = Factory {
        DocumentPackagesProvider(
            componentPackagesProvider: componentPackagesProvider()
        ) as DocumentPackagesProviderProtocol
    }
    
    static let pbxProjSyncer = Factory {
        PBXProjectSyncer(
            packageFolderNameProvider: packageFolderNameProvider(),
            packageNameProvider: packageNameProvider(),
            packagePathProvider: packagePathProvider(),
            projectWriter: pbxProjectWriter(),
            relativeURLProvider: relativeURLProvider()
        ) as PBXProjectSyncerProtocol
    }
    
    static let pbxProjectWriter = Factory {
        PBXProjectWriter() as PBXProjectWriterProtocol
    }
    
    static let projectGenerator = Factory {
        ProjectGenerator(
            documentPackagesProvider: documentPackagesProvider(),
            packageGenerator: packageGenerator()
        ) as ProjectGeneratorProtocol
    }
    
    static let demoAppNameProvider = Factory {
        DemoAppNameProvider() as DemoAppNameProviderProtocol
    }
    
    static let relativeURLProvider = Factory {
        RelativeURLProvider() as RelativeURLProviderProtocol
    }
    
    static let generateFeatureDataStore = Factory(scope: .singleton) {
        GenerateFeatureDataStore(
            dictionaryCache: UserDefaults.standard
        ) as GenerateFeatureDataStoreProtocol
    }
    
    static let projectValidator = Factory(scope: .singleton) {
        ProjectValidator(
            decoder: phoenixDocumentFileWrappersDecoder(),
            packagesValidator: packagesValidator()
        ) as ProjectValidatorProtocol
    }
    
    static let packageValidator = Factory(scope: .singleton) {
        PackageValidator(
            fileManager: .default,
            packageStringProvider: packageStringProvider()
        ) as PackageValidatorProtocol
    }
    
    static let packagesValidator = Factory(scope: .singleton) {
        PackagesValidator(
            documentPackagesProvider: documentPackagesProvider(),
            packageValidator: packageValidator()
        ) as PackagesValidatorProtocol
    }
}
