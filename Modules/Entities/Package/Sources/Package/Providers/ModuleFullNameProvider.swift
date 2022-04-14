public protocol ModuleFullNameProviding {
    func name(for module: ModuleDescription) -> String
}

struct ModuleFullNameProvider: ModuleFullNameProviding {
    func name(for module: ModuleDescription) -> String {
        var fullName = module.name.given + module.name.family

        switch module.type {
        case .contract:
            fullName = fullName + "Contract"
        case .implementation:
            break
        case .mock:
            fullName = fullName + "Mock"
        }

        return fullName
    }
}

