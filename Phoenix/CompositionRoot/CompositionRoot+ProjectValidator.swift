import Factory
import ProjectValidator
import ProjectValidatorContract

extension Container {
    static let projectValidator = Factory(Container.shared) {
        ProjectValidator(
            decoder: phoenixDocumentFileWrappersDecoder(),
            packagesValidator: packagesValidator()
        ) as ProjectValidatorProtocol
    }
    
    static let packageValidator = Factory(Container.shared) {
        PackageValidator(
            fileManager: .default,
            packageStringProvider: packageStringProvider()
        ) as PackageValidatorProtocol
    }
    
    static let packagesValidator = Factory(Container.shared) {
        PackagesValidator(
            documentPackagesProvider: documentPackagesProvider(),
            packageValidator: packageValidator()
        ) as PackagesValidatorProtocol
    }
}
