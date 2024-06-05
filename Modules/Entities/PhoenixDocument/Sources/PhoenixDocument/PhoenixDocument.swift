import Foundation

public struct PhoenixDocument: Hashable {
    public var id: String = UUID().uuidString
    public var families: [ComponentsFamily] {
        didSet {
            components = families.flatMap(\.components).reduce(into: [Name: Component](), { $0[$1.name] = $1 })
            familiesDetails = families.map(\.family).reduce(into: [String: Family](), { $0[$1.name] = $1 })
        }
    }
    public var remoteComponents: [RemoteComponent]
    public var macroComponents: [MacroComponent]
    public var metaComponents: [MetaComponent]
    public var projectConfiguration: ProjectConfiguration
    
    private(set) public var components: [Name: Component]
    private(set) public var familiesDetails: [String: Family]
    
    public init(families: [ComponentsFamily] = [],
                remoteComponents: [RemoteComponent] = [],
                macros: [MacroComponent] = [],
                metas: [MetaComponent] = [],
                projectConfiguration: ProjectConfiguration = .default) {
        self.families = families
        self.remoteComponents = remoteComponents
        self.macroComponents = macros
        self.metaComponents = metas
        self.projectConfiguration = projectConfiguration
        
        self.components = families.flatMap(\.components).reduce(into: [Name: Component](), { $0[$1.name] = $1 })
        self.familiesDetails = families.map(\.family).reduce(into: [String: Family](), { $0[$1.name] = $1 })
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(families.hashValue)
        hasher.combine(remoteComponents.hashValue)
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
    
    public func macro(named name: String) -> MacroComponent? {
        macroComponents.first(where: { $0.name == name })
    }
}
