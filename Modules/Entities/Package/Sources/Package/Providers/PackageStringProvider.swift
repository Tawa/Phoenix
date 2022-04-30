public protocol PackageStringProviding {
    func string(for package: Package) -> String
}

public struct PackageStringProvider: PackageStringProviding {
    
    public init() {
        
    }
    
    public func string(for package: Package) -> String {
        var value: String = """
// swift-tools-version:5.6

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
            value += "    ],\n    targets: [\n"
        } else {
            value += "    targets: [\n"
        }

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
        switch library.type {
        case .static:
            value += "            type: .static,\n"
        case .dynamic:
            value += "            type: .dynamic,\n"
        case .undefined:
            break
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

    private func externalDependencyDescriptionString(_ description: ExternalDependencyVersion) -> String {
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

        if !target.dependencies.isEmpty {
            value += ",\n            dependencies: [\n"
            for dependency in target.dependencies.sorted() {
                value += targetDependencyString(dependency)
            }
            value += "            ]"
        }

        if !target.resources.isEmpty {
            value += ",\n            resources: [\n"
            for resource in target.resources {
                value += "                .\(resource.resourcesType.rawValue)(\"\(resource.folderName)\"),\n"
            }
            value += "            ]"
        }

        value += "\n        ),\n"
        return value
    }

    private func iOSPlatformString(_ iOSPlatform: IOSVersion) -> String {
        ".iOS(.\(iOSPlatform))"
    }

    private func macOSPlatformString(_ macOSVersion: MacOSVersion) -> String {
        switch macOSVersion {
        case .v12:
            return ".macOS(.v12)"
        }
    }
}
