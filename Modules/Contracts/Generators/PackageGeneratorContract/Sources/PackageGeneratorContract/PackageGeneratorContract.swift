import Foundation
import SwiftPackage
import PhoenixDocument
import ProjectGeneratorContract

public protocol PackageGeneratorProtocol {
    func generate(package: SwiftPackage, at url: URL, packages: [PackageWithPath], meta: MetaComponent?) throws
}
