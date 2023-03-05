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
    static let phoenixDocumentFileWrappersDecoder = Factory(Container.shared) {
        PhoenixDocumentFileWrappersDecoder() as PhoenixDocumentFileWrappersDecoderProtocol
    }

    static let phoenixDocumentFileWrapperEncoder = Factory(Container.shared) {
        PhoenixDocumentFileWrapperEncoder(
            currentAppVersionStringProvider: currentAppVersionStringProvider()
        ) as PhoenixDocumentFileWrapperEncoderProtocol
    }
    
    static let packageGenerator = Factory(Container.shared) {
        PackageGenerator(
            fileManager: .default,
            packageStringProvider: packageStringProvider()
        ) as PackageGeneratorProtocol
    }
    
    static let demoAppGenerator = Factory(Container.shared) {
        DemoAppGenerator(
            fileManager: FileManager.default
        ) as DemoAppGeneratorProtocol
    }
    
    static let familyFolderNameProvider = Factory(Container.shared) {
        FamilyFolderNameProvider() as FamilyFolderNameProviderProtocol
    }
    
    static let packageNameProvider = Factory(Container.shared) {
        PackageNameProvider() as PackageNameProviderProtocol
    }
    
    static let packageStringProvider = Factory(Container.shared) {
        PackageStringProvider() as PackageStringProviderProtocol
    }
    
    static let packageFolderNameProvider = Factory(Container.shared) {
        PackageFolderNameProvider(
            defaultFolderNameProvider: familyFolderNameProvider()
        ) as PackageFolderNameProviderProtocol
    }
    
    static let packagePathProvider = Factory(Container.shared) {
        PackagePathProvider(
            packageFolderNameProvider: packageFolderNameProvider(),
            packageNameProvider: packageNameProvider()
        ) as PackagePathProviderProtocol
    }
    
    static let componentPackageProvider = Factory(Container.shared) {
        ComponentPackageProvider(
            packageFolderNameProvider: packageFolderNameProvider(),
            packageNameProvider: packageNameProvider(),
            packagePathProvider: packagePathProvider()
        ) as ComponentPackageProviderProtocol
    }
    
    static let componentPackagesProvider = Factory(Container.shared) {
        ComponentPackagesProvider(
            componentPackageProvider: componentPackageProvider()
        ) as ComponentPackagesProviderProtocol
    }
    
    static let documentPackagesProvider = Factory(Container.shared) {
        DocumentPackagesProvider(
            componentPackagesProvider: componentPackagesProvider()
        ) as DocumentPackagesProviderProtocol
    }
    
    static let pbxProjSyncer = Factory(Container.shared) {
        PBXProjectSyncer(
            packageFolderNameProvider: packageFolderNameProvider(),
            packageNameProvider: packageNameProvider(),
            packagePathProvider: packagePathProvider(),
            projectWriter: pbxProjectWriter(),
            relativeURLProvider: relativeURLProvider()
        ) as PBXProjectSyncerProtocol
    }
    
    static let pbxProjectWriter = Factory(Container.shared) {
        PBXProjectWriter() as PBXProjectWriterProtocol
    }
    
    static let projectGenerator = Factory(Container.shared) {
        ProjectGenerator(
            documentPackagesProvider: documentPackagesProvider(),
            packageGenerator: packageGenerator()
        ) as ProjectGeneratorProtocol
    }
    
    static let demoAppNameProvider = Factory(Container.shared) {
        DemoAppNameProvider() as DemoAppNameProviderProtocol
    }
    
    static let relativeURLProvider = Factory(Container.shared) {
        RelativeURLProvider() as RelativeURLProviderProtocol
    }
    
    static let generateFeatureDataStore = Factory(Container.shared) {
        GenerateFeatureDataStore(
            dictionaryCache: UserDefaults.standard
        ) as GenerateFeatureDataStoreProtocol
    }.scope(.singleton)
    
    static let projectValidator = Factory(Container.shared) {
        ProjectValidator(
            decoder: phoenixDocumentFileWrappersDecoder(),
            packagesValidator: packagesValidator()
        ) as ProjectValidatorProtocol
    }.scope(.singleton)
    
    static let packageValidator = Factory(Container.shared) {
        PackageValidator(
            fileManager: .default,
            packageStringProvider: packageStringProvider()
        ) as PackageValidatorProtocol
    }.scope(.singleton)
    
    static let packagesValidator = Factory(Container.shared) {
        PackagesValidator(
            documentPackagesProvider: documentPackagesProvider(),
            packageValidator: packageValidator()
        ) as PackagesValidatorProtocol
    }.scope(.singleton)
}
