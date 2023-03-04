import Foundation
import PackageStringProviderContract
import SwiftPackage

public enum PackageValidationResult {
    case valid
    case missmatch(String)
    case couldNotLoadPackageManifest
}

public protocol PackageValidatorProtocol {
    func validate(package: SwiftPackage, at url: URL) -> PackageValidationResult
}

public struct PackageValidator: PackageValidatorProtocol {
    let fileManager: FileManager
    let packageStringProvider: PackageStringProviderProtocol
    
    public init(
        fileManager: FileManager,
        packageStringProvider: PackageStringProviderProtocol
    ) {
        self.fileManager = fileManager
        self.packageStringProvider = packageStringProvider
    }
    
    public func validate(package: SwiftPackage, at url: URL) -> PackageValidationResult {
        let localFilePath = url.path.appending("/Package.swift")
        guard
            let localFileData = fileManager.contents(atPath: localFilePath),
            let localPackageString = String(data: localFileData, encoding: .utf8)
        else { return PackageValidationResult.couldNotLoadPackageManifest }
        
        let packageString = packageStringProvider.string(for: package)
        guard packageString == localPackageString
        else { return PackageValidationResult.missmatch("File missmatch") }
        
        return PackageValidationResult.valid
    }
}
