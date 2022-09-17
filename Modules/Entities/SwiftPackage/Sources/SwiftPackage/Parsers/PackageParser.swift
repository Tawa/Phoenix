
public protocol PackageParserProtocol {
    func package(from string: String) -> SwiftPackage
}

public struct PackageParser: PackageParserProtocol {
    public init() {

    }

    public func package(from string: String) -> SwiftPackage {
        SwiftPackage(name: "",
                iOSVersion: nil,
                macOSVersion: nil,
                products: [],
                dependencies: [],
                targets: [],
                swiftVersion: "")
    }
}
