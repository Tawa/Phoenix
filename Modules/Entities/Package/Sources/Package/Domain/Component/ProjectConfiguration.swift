import Foundation

public struct ProjectConfiguration: Codable, Hashable {
    public var packageConfigurations: [PackageConfiguration]
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
