import Factory
import ProjectGenerator
import ProjectGeneratorContract

extension Container {
    static let projectGenerator = Factory(Container.shared) {
        ProjectGenerator(
            documentPackagesProvider: documentPackagesProvider(),
            packageGenerator: packageGenerator()
        ) as ProjectGeneratorProtocol
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
    
    static let macroComponentPackageProvider = Factory(Container.shared) {
        MacroComponentPackageProvider() as MacroComponentPackageProviderProtocol
    }
    
    static let documentPackagesProvider = Factory(Container.shared) {
        DocumentPackagesProvider(
            componentPackagesProvider: componentPackagesProvider(),
            macroComponentPackageProvider: macroComponentPackageProvider()
        ) as DocumentPackagesProviderProtocol
    }
}
