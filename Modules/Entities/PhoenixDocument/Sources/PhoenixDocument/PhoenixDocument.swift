import Component
import Foundation

public struct PhoenixDocument: Codable {
    public let id: String = UUID().uuidString
    public var families: [ComponentsFamily]
    public var projectConfiguration: ProjectConfiguration

    public init(families: [ComponentsFamily] = [],
         projectConfiguration: ProjectConfiguration = .default) {
        self.families = families
        self.projectConfiguration = projectConfiguration
    }
}
