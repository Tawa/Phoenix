import ArgumentParser

import Foundation
import ComponentDetailsProvider
import DocumentCoder
import PhoenixDocument
import PackageStringProvider
import ProjectGenerator
import ProjectValidatorContract
import ProjectValidator

enum CommandLineError: Error {
    case missingArguments(String)
    case missingPhoenixDocument
    case invalidPhoenixDocumentURL
    case invalidModulesFolderURL
    case couldNotFindCurrentDirectory
}

@main struct CommandLineTool {
    static let decoder: PhoenixDocumentFileWrappersDecoder = {
        PhoenixDocumentFileWrappersDecoder()
    }()
    static let projectValidator: ProjectValidator = {
        let familyFolderNameProvider = FamilyFolderNameProvider()
        let packageNameProvider = PackageNameProvider()
        let macroComponentPackageProvider = MacroComponentPackageProvider()
        
        return ProjectValidator(
            decoder: decoder,
            packagesValidator: PackagesValidator(
                documentPackagesProvider: DocumentPackagesProvider(
                    componentPackagesProvider: ComponentPackagesProvider(
                        componentPackageProvider: ComponentPackageProvider(
                            packageFolderNameProvider: PackageFolderNameProvider(
                                defaultFolderNameProvider: familyFolderNameProvider
                            ),
                            packageNameProvider: packageNameProvider,
                            packagePathProvider: PackagePathProvider(
                                packageFolderNameProvider: PackageFolderNameProvider(
                                    defaultFolderNameProvider: familyFolderNameProvider),
                                packageNameProvider: packageNameProvider
                            )
                        )
                    ), macroComponentPackageProvider: macroComponentPackageProvider
                ),
                packageValidator: PackageValidator(
                    fileManager: .default,
                    packageStringProvider: PackageStringProvider()
                )
            )
        )
    }()
    
    static func main() async {
        let arguments = CommandLine.arguments
        
        guard arguments.count > 2
        else {
            print("Input arguments should be \"ash file url\" and \"modules folder url\"")
            exit(1)
        }
        
        guard let currentDirectoryURL = URL(string: FileManager.default.currentDirectoryPath)
        else {
            print("Error getting current working directory")
            exit(1)
        }
                
        let ashFileURL = properURL(path: arguments[1], relativeURL: currentDirectoryURL)
        let modulesFolderURL = properURL(path: arguments[2], relativeURL: currentDirectoryURL)
        
        print("Ash File URL: \(ashFileURL)")
        print("Modules Folder URL: \(modulesFolderURL)")
        
        do {
            let document = try CommandLineTool.loadDocument(at: ashFileURL)
            
            try await projectValidator.validate(document: document,
                                                fileURL: ashFileURL,
                                                modulesFolderURL: modulesFolderURL)
            print("Everything looks good")
            exit(0)
        } catch PackagesValidatorError.projectOutOfSync(let message) {
            print("Project Out Of Sync:\n\(message)")
            exit(1)
        } catch {
            print("Error \(error)")
            exit(1)
        }
    }
    
    static func loadDocument(at url: URL) throws -> PhoenixDocument {
        let fileWrapper = try FileWrapper(url: url)
        guard let fileWrappers = fileWrapper.fileWrappers
        else { throw CommandLineError.missingPhoenixDocument }
        return try decoder.phoenixDocument(from: fileWrappers)
    }
    
    static func properURL(path: String, relativeURL: URL) -> URL {
        let possibleURL = URL(filePath: relativeURL.appending(path: path).path(),
                              directoryHint: .isDirectory)
        if FileManager.default.isDeletableFile(atPath: possibleURL.path) {
            return possibleURL
        }
        return URL(filePath: path, directoryHint: .isDirectory)
    }
}
