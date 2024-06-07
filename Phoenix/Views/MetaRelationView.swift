import AccessibilityIdentifiers
import PhoenixDocument
import SwiftUI

//extension Set where Element == PackageTargetType {
//    func toStringDictionary() -> [PackageTargetType: String] {
//        reduce(into: [PackageTargetType: String]()) { partialResult, packageTargetType in
//            partialResult[packageTargetType] = ""
//        }
//    }
//}
//
//extension Binding where Value == Set<PackageTargetType> {
//    func toStringDictionaryBinding() -> Binding<[PackageTargetType: String]> {
//        Binding<[PackageTargetType: String]> {
//            wrappedValue.toStringDictionary()
//        } set: { newDictionaryValue in
//            wrappedValue = Set(newDictionaryValue.keys)
//        }
//    }
//}
//
//struct RelationViewData {
//    var types: [IdentifiableWithSubtypeAndSelection<PackageTargetType, String>]
//    var selectionValues: [String]
//}

struct MetaRelationSelectorView<DataType>: View where DataType: Hashable {
    let title: String
    let dependencyName: String
    
    let value: DataType?
    let allValues: [DataType]
    let onValueChange: (DataType?) -> Void
    
    var body: some View {
        Toggle(title,
               isOn: .init(get: { value != nil },
                           set: { onValueChange($0 ? allValues[0] : nil) }))
    }
}

struct MetaRelationView: View {
    @Binding var defaultDependencies: [PackageTargetType: String]
    let title: String
    let allTypes: [IdentifiableWithSubtypeAndSelection<PackageTargetType, String>]
    let allSelectionValues: [String]
    let onSelect: (() -> Void)?
    let onRemove: (() -> Void)?

    init(defaultDependencies: Binding<[PackageTargetType: String]>,
         title: String,
         viewData: RelationViewData,
         onSelect: (() -> Void)? = nil,
         onRemove: (() -> Void)? = nil
    ) {
        _defaultDependencies = defaultDependencies
        self.title = title
        self.allTypes = viewData.types
        self.allSelectionValues = viewData.selectionValues
        self.onSelect = onSelect
        self.onRemove = onRemove
    }


    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center) {
                Text(title)
                    .bold()
                onSelect.map { Button(action: $0, label: { Text("Open") }) }
                onRemove.map { Button(action: $0) { Image(systemName: "trash") } }
                Spacer()
            }
            .padding(.bottom)
            LazyVStack {
                ForEach(allTypes) { dependencyType in
                    HStack {
                        MetaRelationSelectorView<String>(
                            title: dependencyType.title,
                            dependencyName: title,
                            value: dependencyType.selectedValue,
                            allValues: allSelectionValues,
                            onValueChange: { defaultDependencies[dependencyType.value] = $0 })
//                        if let subtitle = dependencyType.subtitle,
//                           let subvalue = dependencyType.subValue {
//                            Divider()
//                            RelationSelectorView<String>(
//                                title: subtitle,
//                                dependencyName: title,
//                                value: dependencyType.selectedSubValue,
//                                allValues: allSelectionValues,
//                                onValueChange: { defaultDependencies[subvalue] = $0 })
//                        }
                        Spacer()
                    }
                }
            }
        }.padding()
    }
}
