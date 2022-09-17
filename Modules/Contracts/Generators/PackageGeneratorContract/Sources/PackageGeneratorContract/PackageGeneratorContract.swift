import Foundation
import SwiftPackage

public protocol PackageGeneratorProtocol {
    func generate(package: SwiftPackage, at url: URL) throws
}
