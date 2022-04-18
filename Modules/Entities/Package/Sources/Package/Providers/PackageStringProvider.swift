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
    name: "\(package.name)",
"""
        
        value +=
"""
    platforms: [ .iOS(.v13) ],
"""
        
        value += """
    products: [
"""
        for product in package.products.sorted() {
            value += productString(product)
        }
        
        value +=
"""
    ],
    dependencies: [
"""
        for dependency in package.dependencies.sorted() {
            value += packageDependencyString(dependency)
        }
        
        value +=
"""
    ],
    targets: [
"""
        for target in package.targets.sorted() {
            value += targetString(target)
        }
        value +=
"""
    ]
)
"""
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
            name: "\(library.name)",
"""
        if let type = library.type {
            switch type {
            case .static:
                value += """
            type: .static,
        """
            case .dynamic:
                value += """
                    type: .dynamic,
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
            return """
        .package(path: "\(path)"),
"""
        }
    }
    
    private func targetDependencyString(_ dependency: Dependency) -> String {
        switch dependency {
        case .module(_, let name):
            return """
                "\(name)",
"""
        }
    }
    
    private func targetString(_ target: Target) -> String {
        var value: String = ""
        if target.isTest {
            value +=
"""
        .testTarget(
"""
        } else {
            value +=
"""
        .target(
"""
        }
        value +=
"""
            name: "\(target.name)",
            dependencies: [
"""
        for dependency in target.dependencies.sorted() {
            value += targetDependencyString(dependency)
        }
        value +=
"""
            ]),
"""
        return value
    }
}
