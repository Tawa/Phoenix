
public protocol PackageParserProtocol {
    func package(from string: String) -> Package
}

public struct PackageParser: PackageParserProtocol {
    public init() {

    }

    public func package(from string: String) -> Package {
        Package(name: "",
                iOSVersion: nil,
                macOSVersion: nil,
                products: [],
                dependencies: [],
                targets: [],
                swiftVersion: "")
    }
}
