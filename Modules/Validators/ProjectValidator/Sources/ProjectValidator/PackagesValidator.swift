import Foundation
import PhoenixDocument
import ProjectValidatorContract
import ProjectGeneratorContract

public struct PackagesValidator: PackagesValidatorProtocol {
    let documentPackagesProvider: DocumentPackagesProviderProtocol
    let packageValidator: PackageValidatorProtocol
    
    public init(
        documentPackagesProvider: DocumentPackagesProviderProtocol,
        packageValidator: PackageValidatorProtocol)
    {
        self.documentPackagesProvider = documentPackagesProvider
        self.packageValidator = packageValidator
    }
    
    public func validate(
        document: PhoenixDocument,
        modulesFolderURL: URL
    ) async throws {
        var invalidResults: [String] = []
        let packagesWithPath: [PackageWithPath] = documentPackagesProvider.packages(for: document)
        for packageWithPath in packagesWithPath {
            let url = modulesFolderURL.appendingPathComponent(packageWithPath.path, isDirectory: true)
            let result = packageValidator.validate(package: packageWithPath.package, at: url)
            
            switch result {
            case .valid:
                break
            case .missmatch:
                invalidResults.append(
                    "Package \"\(packageWithPath.package.name)\" is invalid."
                )
            case .couldNotLoadPackageManifest:
                invalidResults.append(
                    "Package \"\(packageWithPath.package.name)\" failed to load or does not exist."
                )
            }
        }
        
        guard invalidResults.isEmpty
        else { throw PackagesValidatorError.projectOutOfSync(invalidResults.joined(separator: "\n")) }
    }
}
