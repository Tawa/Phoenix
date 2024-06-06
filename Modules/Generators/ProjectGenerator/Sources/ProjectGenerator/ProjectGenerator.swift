import ComponentDetailsProviderContract
import Foundation
import PackageGeneratorContract
import PhoenixDocument
import ProjectGeneratorContract
import SwiftPackage

public struct ProjectGenerator: ProjectGeneratorProtocol {
    let documentPackagesProvider: DocumentPackagesProviderProtocol
//    let metaPackagesProvider: MetaComponentPackageProviderProtocol
    let packageGenerator: PackageGeneratorProtocol
    
    public init(
        documentPackagesProvider: DocumentPackagesProviderProtocol,
        packageGenerator: PackageGeneratorProtocol
    ) {
        self.documentPackagesProvider = documentPackagesProvider
        self.packageGenerator = packageGenerator
    }
    
    public func generate(document: PhoenixDocument, folderURL: URL) throws {
        print(document.families.compactMap{$0.family.name})
        print()
        let packagesWithPath: [PackageWithPath] = documentPackagesProvider.packages(for: document)
        for packageWithPath in packagesWithPath {
            let url = folderURL.appendingPathComponent(packageWithPath.path, isDirectory: true)
            try packageGenerator.generate(package: packageWithPath.package, at: url)
        }        
    }
}
