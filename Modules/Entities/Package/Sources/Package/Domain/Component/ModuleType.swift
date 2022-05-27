public struct PackageConfiguration: Codable, Hashable {
    let name: String
    let containerFolderName: String?
    let appendPackageName: Bool
    let internalDependency: String?
    let hasTests: Bool
}

public struct ProjectConfiguration: Codable, Hashable {
    public let packageConfigurations: [PackageConfiguration]
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
