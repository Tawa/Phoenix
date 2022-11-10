import ComponentDetailsProvider
import ComponentDetailsProviderContract
import DemoAppFeature
import DemoAppGenerator
import DemoAppGeneratorContract
import DocumentCoder
import DocumentCoderContract
import Factory
import Foundation
import PackageGenerator
import PackageGeneratorContract
import PackageStringProvider
import PackageStringProviderContract
import PBXProjectSyncer
import PBXProjectSyncerContract
import ProjectGenerator
import ProjectGeneratorContract
import RelativeURLProvider
import RelativeURLProviderContract
import SwiftPackage

import PhoenixDocument
import SwiftUI

class Composition {
    let document: Binding<PhoenixDocument>
    
    init(document: Binding<PhoenixDocument>) {
        self.document = document
        print("Initialising Composition")
    }
    
    deinit {
        print("Deinitialising Composition")
    }
    
    // MARK: - Data
    lazy var phoenixDocumentRepository = Factory(scope: .singleton) { [unowned self] in
        PhoenixDocumentRepository(
            document: self.document
        ) as PhoenixDocumentRepositoryProtocol
    }
    
    lazy var selectionRepository = Factory(scope: .singleton) { [unowned self] in
        SelectionRepository() as SelectionRepositoryProtocol
    }
    
    // MARK: - Domain
    lazy var getComponentsListItemsUseCase = Factory(scope: .singleton) { [unowned self] in
        GetComponentsListItemsUseCase(
            documentRepository: self.phoenixDocumentRepository(),
            familyFolderNameProvider: Container.familyFolderNameProvider(),
            selectionRepository: self.selectionRepository()
        )
    }
    
    lazy var selectComponentUseCase = Factory(scope: .singleton) { [unowned self] in
        SelectComponentUseCase(
            phoenixDocumentRepository: self.phoenixDocumentRepository(),
            selectionRepository: self.selectionRepository()
        ) as SelectComponentUseCaseProtocol
    }
}

extension Container {
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
            packageFolderNameProvider: Container.packageFolderNameProvider(),
            packageNameProvider: Container.packageNameProvider(),
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
            projectWriter: Container.pbxProjectWriter(),
            relativeURLProvider: Container.relativeURLProvider()
        ) as PBXProjectSyncerProtocol
    }
    
    static let pbxProjectWriter = Factory {
        PBXProjectWriter() as PBXProjectWriterProtocol
    }
    
    static let projectGenerator = Factory {
        ProjectGenerator(
            componentPackagesProvider: Container.componentPackagesProvider(),
            packageGenerator: Container.packageGenerator()
        ) as ProjectGeneratorProtocol
    }
    
    static let demoAppNameProvider = Factory {
        DemoAppNameProvider() as DemoAppNameProviderProtocol
    }
        
    static let filesURLDataStore = Factory {
        FilesURLDataStore(
            dictionaryCache: UserDefaults.standard
        ) as FilesURLDataStoreProtocol
    }
    
    static let relativeURLProvider = Factory {
        RelativeURLProvider() as RelativeURLProviderProtocol
    }
}
