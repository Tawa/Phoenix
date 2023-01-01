import Component
import PhoenixDocument

extension PhoenixDocument {
    func mentions(forName name: Name) -> [Name] {
        components
            .map(\.value)
            .filter { otherComponent in
                otherComponent.localDependencies.contains(where: { $0.name == name })
            }
            .map(\.name)
    }
    
    func mentions(forURL url: String) -> [Name] {
        components
            .map(\.value)
            .filter { component in
                component.remoteComponentDependencies.contains(where: { $0.url == url })
            }
            .map(\.name)
    }
}
