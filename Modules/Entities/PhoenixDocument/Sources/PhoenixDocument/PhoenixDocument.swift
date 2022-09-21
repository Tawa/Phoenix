import Component

public struct PhoenixDocument: Codable {
    public var families: [ComponentsFamily]
    public var projectConfiguration: ProjectConfiguration

    public init(families: [ComponentsFamily] = [],
         projectConfiguration: ProjectConfiguration = .default) {
        self.families = families
        self.projectConfiguration = projectConfiguration
    }
}
