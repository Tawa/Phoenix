import Package
import Foundation

public protocol PackageGeneratorProtocol {
    func generate(package: Package, at url: URL) throws
}
