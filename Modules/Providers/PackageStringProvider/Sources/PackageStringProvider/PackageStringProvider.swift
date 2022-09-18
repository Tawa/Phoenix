import PackageStringProviderContract
import SwiftPackage

public struct PackageStringProvider: PackageStringProviderProtocol {
    
    public init() {
        
    }
    
    public func string(for package: SwiftPackage) -> String {
        var value: String = """
// swift-tools-version: \(package.swiftVersion)

import PackageDescription

let package = Package(
    name: "\(package.name)",\n
"""

        if package.iOSVersion != nil || package.macOSVersion != nil {
            value += "    platforms: [\n"
            var versions: [String] = []
            if let iOSVersion = package.iOSVersion {
                versions.append("        \(iOSPlatformString(iOSVersion))")
            }
            if let macOSVersion = package.macOSVersion {
                versions.append("        \(macOSPlatformString(macOSVersion))")
            }
            value += versions.joined(separator: ",\n") + "\n"
            value += "    ],\n"
        }
        value += "    products: [\n"
        value += package.products.sorted().map(productString(_:)).joined(separator: ",\n")
        value += "\n    ],\n"

        if !package.dependencies.isEmpty {
            value += "    dependencies: [\n"
            value += package.dependencies.sorted().map(packageDependencyString(_:)).joined(separator: ",\n") + "\n"
            value += "    ],\n    targets: [\n"
        } else {
            value += "    targets: [\n"
        }

        value += package.targets.sorted().map(targetString(_:)).joined(separator: ",\n") + "\n"
        value += "    ]\n)\n"

        return value
    }
    
    private func productString(_ product: Product) -> String {
        switch product {
        case .library(let library):
            return libraryString(library)
        }
    }
    
    private func libraryString(_ library: Library) -> String {
        var value: String = "        .library(\n            name: \"\(library.name)\",\n"
        switch library.type {
        case .static:
            value += "            type: .static,\n"
        case .dynamic:
            value += "            type: .dynamic,\n"
        case .undefined:
            break
        }
        value += "            targets: [\"\(library.name)\"])"
        return value
    }
    
    private func packageDependencyString(_ dependency: Dependency) -> String {
        switch dependency {
        case .module(let path, _):
            return "        .package(path: \"\(path)\")"
        case .external(let url, _, let description):
            return "        .package(url: \"\(url)\", \(externalDependencyDescriptionString(description)))"
        }
    }

    private func externalDependencyDescriptionString(_ description: ExternalDependencyVersion) -> String {
        switch description {
        case .from(let value):
            return "from: \"\(value)\""
        case .branch(let name):
            return "branch: \"\(name)\""
        case .exact(let value):
            return "exact: \"\(value)\""
        }
    }
    
    private func targetDependencyString(_ dependency: Dependency) -> String {
        switch dependency {
        case .module(_, let name):
            return "                \"\(name)\""
        case .external(_, let name, _):
            switch name {
            case let .name(value):
                return "                \"\(value)\""
            case let.product(name, package):
                return "                .product(name: \"\(name)\", package: \"\(package)\")"
            }
        }
    }
    
    private func targetString(_ target: Target) -> String {
        var value: String = ""
        if target.isTest {
            value += "        .testTarget(\n"
        } else {
            value += "        .target(\n"
        }
        value += "            name: \"\(target.name)\""

        if !target.dependencies.isEmpty {
            value += ",\n            dependencies: [\n"
            value += target.dependencies.sorted().map(targetDependencyString(_:)).joined(separator: ",\n") + "\n"
            value += "            ]"
        }

        //"                .\(resource.resourcesType.rawValue)(\"\(resource.folderName)\")
        if !target.resources.isEmpty {
            value += ",\n            resources: [\n"
            value += target.resources.map { "                .\($0.resourcesType.rawValue)(\"\($0.folderName)\")" }.joined(separator: ",\n") + "\n"
            value += "            ]"
        }

        value += "\n        )"
        return value
    }

    private func iOSPlatformString(_ iOSPlatform: IOSVersion) -> String {
        ".iOS(.\(iOSPlatform))"
    }

    private func macOSPlatformString(_ macOSVersion: MacOSVersion) -> String {
        ".macOS(.\(macOSVersion))"
    }
}
