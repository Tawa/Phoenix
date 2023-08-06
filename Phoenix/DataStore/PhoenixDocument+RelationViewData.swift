import PhoenixDocument

extension PhoenixDocument {
    private func dependencyTypes(
        selectedValues: [PackageTargetType: String]
    ) -> [IdentifiableWithSubtypeAndSelection<PackageTargetType, String>] {
        projectConfiguration.packageConfigurations.map { packageConfiguration in
            IdentifiableWithSubtypeAndSelection(
                title: packageConfiguration.name,
                subtitle: packageConfiguration.hasTests ? "Tests" : nil,
                value: PackageTargetType(name: packageConfiguration.name, isTests: false),
                subValue: packageConfiguration.hasTests ? PackageTargetType(name: packageConfiguration.name, isTests: true) : nil,
                selectedValue: selectedValues[PackageTargetType(name: packageConfiguration.name, isTests: false)],
                selectedSubValue: selectedValues[PackageTargetType(name: packageConfiguration.name, isTests: true)])
        }
    }
    
    func projectConfigurationRelationViewData() -> RelationViewData {
        .init(
            types: dependencyTypes(selectedValues: projectConfiguration.defaultDependencies),
            selectionValues: projectConfiguration.packageConfigurations.map(\.name)
        )
    }
    
    func componentRelationViewData(componentName: Name) -> RelationViewData {
        let component = component(named: componentName)
        
        return .init(
            types: dependencyTypes(selectedValues: component?.defaultDependencies ?? [:]),
            selectionValues: component?.modules.keys.sorted() ?? []
        )
    }
    
    func macroComponentRelationViewData(macroComponentName: String) -> RelationViewData {
        let macroComponent = macro(named: macroComponentName)
        
        return .init(
            types: dependencyTypes(selectedValues: (macroComponent?.defaultDependencies.toStringDictionary()) ?? [:]),
            selectionValues: [""]
        )
    }
    

    func familyRelationViewData(familyName: String) -> RelationViewData {
        let family = family(named: familyName)
        
        return .init(
            types: dependencyTypes(selectedValues: family?.defaultDependencies ?? [:]),
            selectionValues: projectConfiguration.packageConfigurations.map(\.name)
        )
    }

    func relationViewData(
        fromComponentName: Name,
        toComponentName: Name,
        selectedValues: [PackageTargetType: String]
    ) -> RelationViewData {
        let fromComponent = component(named: fromComponentName)
        let toComponent = component(named: toComponentName)
        return .init(
            types: dependencyTypes(selectedValues: selectedValues)
                .filter { value in fromComponent?.modules.keys.contains(where: { value.value.name == $0 }) ?? false },
            selectionValues: toComponent?.modules.keys.sorted() ?? []
        )
    }
    
    func relationViewData(
        fromComponentName: Name,
        toMacroName macroName: String,
        selectedValues: [PackageTargetType: String]
    ) -> RelationViewData {
        let fromComponent = component(named: fromComponentName)
        return .init(
            types: dependencyTypes(selectedValues: selectedValues)
                .filter { value in fromComponent?.modules.keys.contains(where: { value.value.name == $0 }) ?? false },
            selectionValues: [""]
        )
    }
}
