import Component
import Foundation

public struct PhoenixDocument: Hashable {
    public var id: String = UUID().uuidString
    public var families: [ComponentsFamily] {
        didSet {
            components = families.flatMap(\.components).reduce(into: [Name: Component](), { $0[$1.name] = $1 })
            familiesDetails = families.map(\.family).reduce(into: [String: Family](), { $0[$1.name] = $1 })
        }
    }
    public var projectConfiguration: ProjectConfiguration
    
    public var components: [Name: Component]
    public var familiesDetails: [String: Family]
    
    public init(families: [ComponentsFamily] = [],
         projectConfiguration: ProjectConfiguration = .default) {
        self.families = families
        self.components = families.flatMap(\.components).reduce(into: [Name: Component](), { $0[$1.name] = $1 })
        self.familiesDetails = families.map(\.family).reduce(into: [String: Family](), { $0[$1.name] = $1 })
        
        self.projectConfiguration = projectConfiguration
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(families.hashValue)
        hasher.combine(projectConfiguration.hashValue)
    }
    
    public func component(named name: Name) -> Component? {
        components[name]
    }
    
    public func family(named name: String) -> Family? {
        familiesDetails[name]
    }
    
    public func title(forComponentNamed name: Name) -> String {
        guard let family = family(named: name.family)
        else { return name.full }
        var name = name.given
        if !family.ignoreSuffix {
            name += family.name
        }
        return name
    }
}
