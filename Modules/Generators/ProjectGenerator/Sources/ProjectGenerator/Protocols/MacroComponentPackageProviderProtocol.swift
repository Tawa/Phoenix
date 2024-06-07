import PhoenixDocument
import ProjectGeneratorContract
import SwiftPackage

public protocol MacroComponentPackageProviderProtocol {
    func package(for macroComponent: MacroComponent,
                 projectConfiguration: ProjectConfiguration) -> PackageWithPath
}

public protocol MetaComponentPackageProviderProtocol {
    func package(for metaComponent: MetaComponent,
                 projectConfiguration: ProjectConfiguration) -> PackageWithPath
}
