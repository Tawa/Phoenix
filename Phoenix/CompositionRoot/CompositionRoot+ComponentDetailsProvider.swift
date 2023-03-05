import ComponentDetailsProvider
import ComponentDetailsProviderContract
import Factory

extension Container {
    static let familyFolderNameProvider = Factory(Container.shared) {
        FamilyFolderNameProvider() as FamilyFolderNameProviderProtocol
    }
    
    static let packageNameProvider = Factory(Container.shared) {
        PackageNameProvider() as PackageNameProviderProtocol
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
}
