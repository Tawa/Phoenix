protocol ComponentModulesProviding {
    func modules(for component: Component) -> [ModulePackageDescription]
}

struct ComponentModulesProvider: ComponentModulesProviding {
    let moduleFullNameProvider: ModuleFullNameProviding

    init(moduleFullNameProvider: ModuleFullNameProviding) {
        self.moduleFullNameProvider = moduleFullNameProvider
    }

    func modules(for component: Component) -> [ModulePackageDescription] {
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

    private func contractModule(for component: Component) -> ModulePackageDescription {
        let name = moduleFullNameProvider.name(for: ModuleDescription(name: component.name, type: .contract))
        return ModulePackageDescription(module: ModuleDescription(name: component.name,
                                                                  type: .contract),
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

    private func implementationModule(for component: Component) -> ModulePackageDescription {
        let name = moduleFullNameProvider.name(for: ModuleDescription(name: component.name, type: .implementation))
        return ModulePackageDescription(module: ModuleDescription(name: component.name,
                                                                  type: .implementation),
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

    private func mockModule(for component: Component) -> ModulePackageDescription {
        let contractName = moduleFullNameProvider.name(for: ModuleDescription(name: component.name, type: .contract))
        let mockName = moduleFullNameProvider.name(for: ModuleDescription(name: component.name, type: .mock))
        return ModulePackageDescription(module: ModuleDescription(name: component.name,
                                                                  type: .mock),
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
