public protocol PackageStringProviding {
    func string(for package: Package) -> String
}

public struct PackageStringProvider: PackageStringProviding {
    
    public init() {
        
    }
    
    public func string(for package: Package) -> String {
        var value: String = """
// swift-tools-version:5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "\(package.name)",\n
"""

        if package.iOSVersion != nil || package.macOSVersion != nil {
            value += "    platforms: [\n"
            if let iOSVersion = package.iOSVersion {
                value += "        \(iOSPlatformString(iOSVersion)),\n"
            }
            if let macOSVersion = package.macOSVersion {
                value += "        \(macOSPlatformString(macOSVersion)),\n"
            }

            value += "    ],\n"
        }
        value += "    products: [\n"
        for product in package.products.sorted() {
            value += productString(product)
        }
        value += "\n    ],\n"

        if !package.dependencies.isEmpty {
            value += "    dependencies: [\n"
            for dependency in package.dependencies.sorted() {
                value += packageDependencyString(dependency)
            }
        }
        
        value += "    ],\n    targets: [\n"
        for target in package.targets.sorted() {
            value += targetString(target)
        }
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
        if let type = library.type {
            switch type {
            case .static:
                value += "            type: .static,\n"
            case .dynamic:
                value += "            type: .dynamic,\n"
            }
        }
        value += "            targets: [\"\(library.name)\"]),"
        return value
    }
    
    private func packageDependencyString(_ dependency: Dependency) -> String {
        switch dependency {
        case .module(let path, _):
            return "        .package(path: \"\(path)\"),\n"
        case .external(let url, _, let description):
            return "        .package(url: \"\(url)\", \(externalDependencyDescriptionString(description))),\n"
        }
    }

    private func externalDependencyDescriptionString(_ description: ExternalDependencyDescription) -> String {
        switch description {
        case .from(let value):
            return "from: \"\(value)\""
        case .branch(let name):
            return "branch: \"\(name)\""
        }
    }
    
    private func targetDependencyString(_ dependency: Dependency) -> String {
        switch dependency {
        case .module(_, let name):
            return "                \"\(name)\",\n"
        case .external(_, let name, _):
            switch name {
            case let .name(value):
                return "                \"\(value)\",\n"
            case let.product(name, package):
                return "                .product(name: \"\(name)\", package: \"\(package)\"),\n"
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
        value += !target.dependencies.isEmpty ? ",\n" : "\n"

        if !target.dependencies.isEmpty {
            value += ",\n            dependencies: [\n"
            for dependency in target.dependencies.sorted() {
                value += targetDependencyString(dependency)
            }
            value += "            ]\n"
        }

        value += "        ),\n"
        return value
    }

    private func iOSPlatformString(_ iOSPlatform: IOSVersion) -> String {
        switch iOSPlatform {
        case .v13:
            return ".iOS(.v13)"
        case .v14:
            return ".iOS(.v14)"
        case .v15:
            return ".iOS(.v15)"
        }
    }

    private func macOSPlatformString(_ macOSVersion: MacOSVersion) -> String {
        switch macOSVersion {
        case .v12:
            return ".macOS(.v12)"
        }
    }
}
