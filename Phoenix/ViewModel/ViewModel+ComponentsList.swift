import PhoenixDocument

extension ViewModel {
    
    func numberOfComponentsAndPackagesText(document: PhoenixDocument) -> String {
        var text: String = ""
        
        let components: [Component] = document.components.values.map { $0 }
        
        let totalComponents = components.count
        if totalComponents == 1 {
            text += "1 component"
        } else {
            text += "\(totalComponents) components"
        }
        
        let totalPackages = components.reduce(0, { $0 + $1.modules.count })
        
        if totalPackages != totalComponents {
            text += "\n("
            if totalPackages == 1 {
                text += "1 swift package"
            } else {
                text += "\(totalPackages) swift packages"
            }
            text += ")"
        }
        
        return text
    }
    
    func componentsListSections(document: PhoenixDocument) -> [ComponentsListSection] {
        componentsListSections(
            document: document,
            selectedName: selection?.componentName,
            filter: componentsListFilter
        )
    }
    
    private func componentsListSections(
        document: PhoenixDocument,
        selectedName: Name?,
        filter: String?
    ) -> [ComponentsListSection] {
        document
            .families
            .compactMap { componentsFamily in
                var componentsFamily = componentsFamily
                componentsFamily.components = componentsFamily.components
                    .filter { component in
                        let name = document.title(forComponentNamed: component.name)
                        if let filter = filter?.lowercased(),
                           !filter.isEmpty,
                           !name.lowercased().contains(filter) {
                            return false
                        }
                        return true
                    }
                return componentsFamily.components.isEmpty ? nil : componentsFamily
            }
            .enumerated()
            .compactMap { componentsFamilyElement in
                let componentsFamily = componentsFamilyElement.element
                let section: ComponentsListSection = .init(
                    id: componentsFamily.family.name,
                    name: sectionTitle(forFamily: componentsFamily.family),
                    folderName: sectionFolderName(forFamily: componentsFamily.family),
                    rows: componentsFamily.components.enumerated().compactMap { componentElement in
                        let component = componentElement.element
                        let name = document.title(forComponentNamed: component.name)
                        return .init(
                            id: component.name,
                            name: name,
                            isSelected: componentElement.element.name == selectedName
                        )
                    }
                )
                if section.rows.isEmpty { return nil }
                return section
            }
    }
    
    private func sectionTitle(forFamily family: Family) -> String {
        family.name == family.folder ? family.name : familyFolderNameProvider.folderName(forFamily: family.name)
    }
    
    private func sectionFolderName(forFamily family: Family) -> String? {
        let result = family.folder ?? familyFolderNameProvider.folderName(forFamily: family.name)
        guard result != family.name
        else { return nil }
        return result
    }
}
