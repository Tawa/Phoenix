public protocol PackageStringProviding {
    func string(for package: Package) -> String
}

public struct PackageStringProvider: PackageStringProviding {
    
    public init() {
        
    }
    
    public func string(for package: Package) -> String {
        var value: String = """
// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "\(package.name)",\n
"""
        
        value +=
"""
    platforms: [ .iOS(.v13) ],\n
"""
        value += "    products: [\n"
        for product in package.products.sorted() {
            value += productString(product)
        }
        value += "\n    ],\n"
        
        value += "    dependencies: [\n"
        for dependency in package.dependencies.sorted() {
            value += packageDependencyString(dependency)
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
        var value: String = """
        .library(
            name: "\(library.name)",\n
"""
        if let type = library.type {
            switch type {
            case .static:
                value += """
            type: .static,\n
        """
            case .dynamic:
                value += """
                    type: .dynamic,\n
        """
            }
        }
        value += """
            targets: ["\(library.name)"]),
"""
        return value
    }
    
    private func packageDependencyString(_ dependency: Dependency) -> String {
        switch dependency {
        case .module(let path, _):
            return "        .package(path: \"\(path)\"),\n"
        }
    }
    
    private func targetDependencyString(_ dependency: Dependency) -> String {
        switch dependency {
        case .module(_, let name):
            return "                \"\(name)\",\n"
        }
    }
    
    private func targetString(_ target: Target) -> String {
        var value: String = ""
        if target.isTest {
            value += "        .testTarget(\n"
        } else {
            value += "        .target(\n"
        }
        value += "            name: \"\(target.name)\",\n            dependencies: [\n"
        for dependency in target.dependencies.sorted() {
            value += targetDependencyString(dependency)
        }
        value += "            ]),\n"
        return value
    }
}
