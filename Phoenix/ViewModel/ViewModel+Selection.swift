import Component
import SwiftUI
import PhoenixDocument

extension ViewModel {
    
    // MARK: - Component
    func selectNextComponent(names: [Name]) {
        var names = names
        if let componentsListFilter {
            names = names.filter { $0.full.lowercased().contains(componentsListFilter.lowercased()) }
        }
        guard let selectedComponentName,
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
        guard let selectedComponentName,
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
            let selectedComponentName,
            let familyIndex = document.wrappedValue.families.firstIndex(where: { $0.family.name == selectedComponentName.family }),
            let componentIndex = document.wrappedValue.families[familyIndex].components.firstIndex(where: { $0.name == selectedComponentName })
        else { return nil }
        return Binding(
            get: { document.wrappedValue.families[familyIndex].components[componentIndex] },
            set: { document.wrappedValue.families[familyIndex].components[componentIndex] = $0 }
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
}
