import SwiftPackage
import SwiftUI

struct ComponentModuleTypesView: View {
    @Binding var dictionary: [String: LibraryType]
    let allModuleTypes: [String]
    let allLibraryTypes: [LibraryType] = LibraryType.allCases
    
    var body: some View {
        VStack {
            ForEach(allModuleTypes, id: \.self) { moduleType in
                ComponentModuleTypeView(
                    title: "\(moduleType)",
                    isOn: Binding(
                        get: { dictionary[moduleType] != nil },
                        set: {
                            if $0 {
                                dictionary[moduleType] = .undefined
                            } else {
                                dictionary.removeValue(forKey: moduleType)
                            }
                        }
                    ),
                    selectionData: allLibraryTypes,
                    selectionTitle: dictionary[moduleType]?.rawValue ?? "undefined",
                    onSelection: { dictionary[moduleType] = $0 },
                    onRemove: { dictionary.removeValue(forKey: moduleType) })
                
            }
        }
    }
}

struct ComponentModuleTypeView: View {
    let title: String
    @Binding var isOn: Bool
    let selectionData: [LibraryType]
    let selectionTitle: String
    let onSelection: (LibraryType) -> Void
    let onRemove: () -> Void
    
    var body: some View {
        HStack {
            Toggle(title, isOn: $isOn)
            if isOn {
                CustomMenu(title: selectionTitle,
                           data: selectionData,
                           onSelection: onSelection,
                           hasRemove: false,
                           onRemove: onRemove)
            }
            Spacer()
        }
    }
}
