import Foundation
import Package

struct PackageGenerator {
    func generate(package: Package, at url: URL) throws {
        print("Should generate: \(package.name) at \(url)")
    }
}
