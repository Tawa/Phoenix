import ComponentDetailsProviderContract
import Foundation
import PackageGeneratorContract
import PhoenixDocument
import ProjectGeneratorContract
import SwiftPackage

public struct ProjectGenerator: ProjectGeneratorProtocol {
    let documentPackagesProvider: DocumentPackagesProviderProtocol
    let packageGenerator: PackageGeneratorProtocol
    
    public init(
        documentPackagesProvider: DocumentPackagesProviderProtocol,
        packageGenerator: PackageGeneratorProtocol
    ) {
        self.documentPackagesProvider = documentPackagesProvider
        self.packageGenerator = packageGenerator
    }
    
    public func generate(document: PhoenixDocument, folderURL: URL) throws {
        let packagesWithPath: [PackageWithPath] = documentPackagesProvider.packages(for: document)
        print(packagesWithPath)
        for packageWithPath in packagesWithPath {
            print("\n \(packageWithPath)")
            let url = folderURL.appendingPathComponent(packageWithPath.path, isDirectory: true)
            try packageGenerator.generate(package: packageWithPath.package, at: url)
        }        
    }
}
