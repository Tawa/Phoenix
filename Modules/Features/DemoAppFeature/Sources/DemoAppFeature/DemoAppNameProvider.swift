import PhoenixDocument

public protocol DemoAppNameProviderProtocol {
    func demoAppName(for component: Component, family: Family) -> String
}

public struct DemoAppNameProvider: DemoAppNameProviderProtocol {
    public init () {
        
    }
    
    public func demoAppName(for component: Component, family: Family) -> String {
        (family.ignoreSuffix ? component.name.given : component.name.full) + "DemoApp"
    }
}

