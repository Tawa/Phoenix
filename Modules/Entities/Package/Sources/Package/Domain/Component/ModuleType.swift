import Foundation
public struct PackageConfiguration: Codable, Hashable, Identifiable {
    public var id: Int { hashValue }
    public var name: String
    public var containerFolderName: String?
    public var appendPackageName: Bool
    public var internalDependency: String?
    public var hasTests: Bool

    public init(name: String, containerFolderName: String? = nil, appendPackageName: Bool, internalDependency: String? = nil, hasTests: Bool) {
        self.name = name
        self.containerFolderName = containerFolderName
        self.appendPackageName = appendPackageName
        self.internalDependency = internalDependency
        self.hasTests = hasTests
    }
}

public struct ProjectConfiguration: Codable, Hashable {
    public var packageConfigurations: [PackageConfiguration]
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
        .init(name: "Implementation",
              containerFolderName: nil,
              appendPackageName: false,
              internalDependency: nil,
              hasTests: true)
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
