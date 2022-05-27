public struct PackageConfiguration: Codable, Hashable {
    public let name: String
    public let containerFolderName: String?
    public let appendPackageName: Bool
    public let internalDependency: String?
    public let hasTests: Bool
}

public struct ProjectConfiguration: Codable, Hashable {
    public let packageConfigurations: [PackageConfiguration]
}

public struct PackageTargetType: Codable, Hashable, Identifiable {
    public var id: Int { hashValue }
    public let name: String
    public let isTests: Bool

    public init(name: String, isTests: Bool) {
        self.name = name
        self.isTests = isTests
    }
}

extension ProjectConfiguration {
    public static let `default`: ProjectConfiguration = .init(packageConfigurations: [
        .init(name: "Contract",
              containerFolderName: "Contracts",
              appendPackageName: true,
              internalDependency: nil,
              hasTests: false),
        .init(name: "Implementation",
              containerFolderName: nil,
              appendPackageName: true,
              internalDependency: "Contract",
              hasTests: true),
        .init(name: "Mock",
              containerFolderName: "Mocks",
              appendPackageName: true,
              internalDependency: nil,
              hasTests: false)
    ])
}


public enum ModuleType: String, Codable, Hashable, Identifiable, CaseIterable, Comparable {
    public var id: Int { hashValue }
    
    case contract
    case implementation
    case mock
    
    public static func <(lhs: ModuleType, rhs: ModuleType) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
