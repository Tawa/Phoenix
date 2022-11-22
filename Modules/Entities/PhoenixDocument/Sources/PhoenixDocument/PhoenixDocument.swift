import Component
import Foundation

public struct PhoenixDocument: Codable, Hashable {
    public var id: String = UUID().uuidString
    public var families: [ComponentsFamily]
    public var projectConfiguration: ProjectConfiguration

    public init(families: [ComponentsFamily] = [],
         projectConfiguration: ProjectConfiguration = .default) {
        self.families = families
        self.projectConfiguration = projectConfiguration
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(families.hashValue)
        hasher.combine(projectConfiguration.hashValue)
    }
}
