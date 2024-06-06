import SwiftUI
import PhoenixDocument

extension ViewModel {
    
    // MARK: - Component
    func selectNextComponent(names: [Name]) {
        var names = names
        if let componentsListFilter {
            names = names.filter { $0.full.lowercased().contains(componentsListFilter.lowercased()) }
        }
        guard let selectedComponentName = selection?.componentName,
              let index = names.firstIndex(of: selectedComponentName)
        else {
            names.first.map(select(componentName:))
            return
        }
        let nextIndex = (index + 1) % names.count
        select(componentName: names[nextIndex])
    }
    
    func selectPreviousComponent(names: [Name]) {
        var names = names
        if let componentsListFilter {
            names = names.filter { $0.full.lowercased().contains(componentsListFilter.lowercased()) }
        }
        guard let selectedComponentName = selection?.componentName,
              let index = names.firstIndex(of: selectedComponentName)
        else {
            names.last.map(select(componentName:))
            return
        }
        let previousIndex = index > 0 ? index - 1 : names.count - 1
        select(componentName: names[previousIndex])
    }
    
    func selectedComponent(document: Binding<PhoenixDocument>) -> Binding<Component>? {
        guard
            let selectedComponentName = selection?.componentName,
            let familyIndex = document.wrappedValue.families.firstIndex(where: { $0.family.name == selectedComponentName.family }),
            let componentIndex = document.wrappedValue.families[familyIndex].components.firstIndex(where: { $0.name == selectedComponentName })
        else { return nil }
        return Binding(
            get: { document.wrappedValue.families[familyIndex].components[componentIndex] },
            set: { document.wrappedValue.families[familyIndex].components[componentIndex] = $0 }
        )
    }
    
    // MARK: - RemoteComponent
    func selectNextRemoteComponent(remoteComponents: [RemoteComponent]) {
        let urls = remoteComponents.filtered(componentsListFilter).map(\.url)
        guard let selectedURL = selection?.remoteComponentURL,
              let index = urls.firstIndex(of: selectedURL)
        else {
            urls.first.map(select(remoteComponentURL:))
            return
        }
        let nextIndex = (index + 1) % urls.count
        select(remoteComponentURL: urls[nextIndex])
    }
    
    func selectPreviousRemoteComponent(remoteComponents: [RemoteComponent]) {
        let urls = remoteComponents.filtered(componentsListFilter).map(\.url)
        guard let selectedURL = selection?.remoteComponentURL,
              let index = urls.firstIndex(of: selectedURL)
        else {
            urls.last.map(select(remoteComponentURL:))
            return
        }
        let previousIndex = index > 0 ? index - 1 : urls.count - 1
        select(remoteComponentURL: urls[previousIndex])
    }
    
    func selectedRemoteComponent(document: Binding<PhoenixDocument>) -> Binding<RemoteComponent>? {
        guard
            let selectedComponentURL = selection?.remoteComponentURL,
            let remoteComponentIndex = document.wrappedValue.remoteComponents.firstIndex(where: { $0.url == selectedComponentURL })
        else { return nil }
        return Binding(
            get: { document.wrappedValue.remoteComponents[remoteComponentIndex] },
            set: { document.wrappedValue.remoteComponents[remoteComponentIndex] = $0 }
        )
    }
    
    // MARK: - Macros
    func selectNextMacro(ids: [MacroComponent.ID]) {
        guard
            let selectedMacroId = selection?.macroId,
            let index = ids.firstIndex(of: selectedMacroId)
        else {
            ids.first.map(select(macro:))
            return
        }
        let nextIndex = (index + 1) % ids.count
        select(macro: ids[nextIndex])
    }
    
    func selectPreviousMacro(ids: [String]) {
        guard
            let selectedMacroId = selection?.macroId,
            let index = ids.firstIndex(of: selectedMacroId)
        else {
            ids.first.map(select(macro:))
            return
        }
        let nextIndex = index > 0 ? index - 1 : ids.count - 1
        select(macro: ids[nextIndex])
    }

    func selectedMacro(document: Binding<PhoenixDocument>) -> Binding<MacroComponent>? {
        guard
            let selectedMacroId = selection?.macroId,
            let macroIndex = document.wrappedValue.macroComponents.firstIndex(where: { $0.id == selectedMacroId })
        else { return nil }
        return Binding(
            get: { document.wrappedValue.macroComponents[macroIndex] },
            set: { document.wrappedValue.macroComponents[macroIndex] = $0 }
        )
    }

    func selectedMeta(document: Binding<PhoenixDocument>) -> Binding<MetaComponent>? {
        guard
            let selectedMetaId = selection?.metaId,
            let metaIndex = document.wrappedValue.metaComponents.firstIndex(where: { $0.id == selectedMetaId })
        else { return nil }
        return Binding(
            get: { document.wrappedValue.metaComponents[metaIndex] },
            set: { document.wrappedValue.metaComponents[metaIndex] = $0 }
        )
    }

    // MARK: - Family
    func selectedFamily(document: Binding<PhoenixDocument>) -> Binding<Family>? {
        guard
            let selectedFamilyName,
            let index = document.wrappedValue.families.firstIndex(where: { $0.family.name == selectedFamilyName })
        else { return nil }
        return Binding(
            get: { document.wrappedValue.families[index].family },
            set: { document.wrappedValue.families[index].family = $0 }
        )
    }
    
    func allRules(for family: Family, document: PhoenixDocument) -> [FamilyRule] {
        document.families.map(\.family).map { otherFamily in
            FamilyRule(
                name: otherFamily.name,
                enabled: !family.excludedFamilies.contains(where: { otherFamily.name == $0 }))
        }
    }
    
    // MARK: - Quick Selection
    func quickSelectionRows(document: PhoenixDocument) -> [QuickSelectionRow] {
        document.families
            .flatMap(\.components)
            .map(\.name)
            .map { name in
                QuickSelectionRow(
                    text: document.title(forComponentNamed: name),
                    terms: [name.full.lowercased()]) { [weak self] in
                        self?.select(componentName: name)
                    }
            } + document.remoteComponents
            .map { remoteComponent in
                QuickSelectionRow(
                    text: remoteComponent.url,
                    terms: [remoteComponent.url.lowercased()] +
                    remoteComponent.names.map { $0.name.lowercased() } +
                    remoteComponent.names.compactMap { $0.package?.lowercased() } ) { [weak self] in
                        self?.select(remoteComponentURL: remoteComponent.url)
                    }
            }
    }
}
