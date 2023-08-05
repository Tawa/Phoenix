import PackageStringProviderContract
import SwiftPackage

extension Sequence where Element: Hashable {
    func uniqued() -> [Element] {
        var set = Set<Element>()
        return filter { set.insert($0).inserted }
    }
}

public struct PackageStringProvider: PackageStringProviderProtocol {
    
    public init() {
        
    }
    
    public func string(for package: SwiftPackage) -> String {
        var value: String = """
// swift-tools-version: \(package.swiftVersion)

\(getImports(for: package))

let package = Package(
    name: "\(package.name)",\n
"""
        if let defaultLocalization = package.defaultLocalization {
            value += "    defaultLocalization: \"\(defaultLocalization)\",\n"
        }
        
        if package.iOSVersion != nil ||
            package.macCatalystVersion != nil ||
            package.macOSVersion != nil ||
            package.tvOSVersion != nil ||
            package.watchOSVersion != nil {
            value += "    platforms: [\n"
            var versions: [String] = []
            if let iOSVersion = package.iOSVersion {
                versions.append("        \(iOSPlatformString(iOSVersion))")
            }
            if let macCatalystVersion = package.macCatalystVersion {
                versions.append("        \(macCatalystPlatformString(macCatalystVersion))")
            }
            if let macOSVersion = package.macOSVersion {
                versions.append("        \(macOSPlatformString(macOSVersion))")
            }
            if let tvOSVersion = package.tvOSVersion {
                versions.append("        \(tvOSPlatformString(tvOSVersion))")
            }
            if let watchOSVersion = package.watchOSVersion {
                versions.append("        \(watchOSPlatformString(watchOSVersion))")
            }
            value += versions.joined(separator: ",\n") + "\n"
            value += "    ],\n"
        }
        value += "    products: [\n"
        value += package.products.sorted().map(productString(_:)).joined(separator: ",\n")
        value += "\n    ],\n"

        if !package.dependencies.isEmpty {
            value += "    dependencies: [\n"
            value += package.dependencies.sorted().map(packageDependencyString(_:)).uniqued().joined(separator: ",\n") + "\n"
            value += "    ],\n    targets: [\n"
        } else {
            value += "    targets: [\n"
        }

        value += package.targets.sorted().map(targetString(_:)).joined(separator: ",\n") + "\n"
        value += "    ]\n)\n"

        return value
    }
    
    private func getImports(for package: SwiftPackage) -> String {
        var value = "import PackageDescription"
        if package.targets.contains(where: { $0.type == .macro }) {
            value += "\nimport CompilerPluginSupport"
        }
        return value
    }
    
    private func productString(_ product: Product) -> String {
        switch product {
        case .executable(let executable):
            return executableString(executable)
        case .library(let library):
            return libraryString(library)
        }
    }

    private func executableString(_ executable: Executable) -> String {
        var value: String = "        .executable(\n            name: \"\(executable.name)\",\n"
        value += "            targets: [\"\(executable.name)\"])"
        return value
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
        value += "        .\(target.type.rawValue)(\n"
        value += "            name: \"\(target.name)\""

        if !target.dependencies.isEmpty {
            value += ",\n            dependencies: [\n"
            value += target.dependencies.sorted().map(targetDependencyString(_:)).joined(separator: ",\n") + "\n"
            value += "            ]"
        }

        if !target.resources.isEmpty {
            value += ",\n            resources: [\n"
            value += target.resources.map { "                .\($0.resourcesType.rawValue)(\"\($0.folderName)\")" }.joined(separator: ",\n") + "\n"
            value += "            ]"
        }

        value += "\n        )"
        return value
    }

    private func iOSPlatformString(_ iOSVersion: IOSVersion) -> String {
        ".iOS(.\(iOSVersion))"
    }

    private func macCatalystPlatformString(_ macCatalystVersion: MacCatalystVersion) -> String {
        ".macCatalyst(.\(macCatalystVersion))"
    }
    
    private func macOSPlatformString(_ macOSVersion: MacOSVersion) -> String {
        ".macOS(.\(macOSVersion))"
    }

    private func tvOSPlatformString(_ tvOSVersion: TVOSVersion) -> String {
        ".tvOS(.\(tvOSVersion))"
    }

    private func watchOSPlatformString(_ watchOSVersion: WatchOSVersion) -> String {
        ".watchOS(.\(watchOSVersion))"
    }
}
