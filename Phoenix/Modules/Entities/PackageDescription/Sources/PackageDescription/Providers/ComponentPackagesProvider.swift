protocol ComponentModulesProviding {
    func modules(for component: Component) -> [ModuleDescription]
}

struct ComponentModulesProvider: ComponentModulesProviding {
    func modules(for component: Component) -> [ModuleDescription] {
        component.types.compactMap { type in
            switch type {
            case .contract:
                return contractModule(for: component)
            case .implementation:
                return implementationModule(for: component)
            case .mock:
                return mockModule(for: component)
            }
        }
    }

    private func fullName(for component: Component) -> String {
        component.name.given + component.name.family
    }

    private func contractModule(for component: Component) -> ModuleDescription {
        let name = fullName(for: component) + "Contract"
        return ModuleDescription(name: component.name,
                                 type: .contract,
                                 package: PackageDescription(name: name,
                                                             platforms: component.platforms,
                                                             products: [
                                                                .library(.init(name: name,
                                                                               type: .dynamic,
                                                                               targets: [name]))
                                                             ],
                                                             targets: [
                                                                Target(name: name,
                                                                       dependencies: [],
                                                                       isTest: false)
                                                             ])
        )
    }

    private func implementationModule(for component: Component) -> ModuleDescription {
        let name = fullName(for: component)
        return ModuleDescription(name: component.name,
                                 type: .implementation,
                                 package: PackageDescription(name: name,
                                                             platforms: component.platforms,
                                                             products: [
                                                                .library(.init(name: name,
                                                                               type: .static,
                                                                               targets: [name]))
                                                             ],
                                                             targets: [
                                                                Target(name: name,
                                                                       dependencies: [name + "Contract"],
                                                                       isTest: false),
                                                                Target(name: name + "Tests",
                                                                       dependencies: [name],
                                                                       isTest: true)
                                                             ])
        )
    }

    private func mockModule(for component: Component) -> ModuleDescription {
        let name = fullName(for: component)
        let contractName = name + "Contract"
        let mockName = name + "Mock"
        return ModuleDescription(name: component.name,
                                 type: .mock,
                                 package: PackageDescription(name: mockName,
                                                             platforms: component.platforms,
                                                             products: [
                                                                .library(.init(name: mockName,
                                                                               type: .dynamic,
                                                                               targets: [mockName]))
                                                             ],
                                                             targets: [
                                                                Target(name: mockName,
                                                                       dependencies: [contractName],
                                                                       isTest: false)])
        )
    }
}
