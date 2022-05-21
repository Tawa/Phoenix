import SwiftUI

struct DependencyModuleTypeSelectorView<DataType>: View where DataType: Identifiable {
    let title: String

    let value: DataType?
    let allValues: [DataType]
    let onValueChange: (DataType?) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
            Menu {
                ForEach(allValues) { type in
                    Button(String(describing: type), action: { onValueChange(type) })
                }
                if value != nil {
                    Divider()
                    Button(action: { onValueChange(nil) }, label: { Text("Remove") })
                }
            } label: {
                if let value = value {
                    Text(String(describing: value))
                } else {
                    Text("Add")
                }
            }
        }
    }
}

struct DependencyView<TargetType, SelectionType>: View
where TargetType: Identifiable, SelectionType: Identifiable {
    let title: String
    let onSelection: () -> Void
    let onRemove: () -> Void

    let allTypes: [IdentifiableWithSubtypeAndSelection<TargetType, SelectionType>]
    let allSelectionValues: [SelectionType]
    let onUpdateTargetTypeValue: (TargetType, SelectionType?) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(title)
                    .font(.title)
                Button(action: onSelection) { Text("Jump to") }
                Button(action: onRemove) { Text("Remove") }
            }
            HStack(alignment: .top) {
                ForEach(allTypes) { dependencyType in
                    VStack {
                        DependencyModuleTypeSelectorView<SelectionType>(
                            title: dependencyType.title,
                            value: dependencyType.selectedValue,
                            allValues: allSelectionValues,
                            onValueChange: { onUpdateTargetTypeValue(dependencyType.value, $0) })

                        if let subtitle = dependencyType.subtitle,
                           let subvalue = dependencyType.subValue {
                            DependencyModuleTypeSelectorView<SelectionType>(
                                title: subtitle,
                                value: dependencyType.selectedSubValue,
                                allValues: allSelectionValues,
                                onValueChange: { onUpdateTargetTypeValue(subvalue, $0) })
                        }
                    }
                }
            }
        }.padding()
    }
}

struct DependencyView_Previews: PreviewProvider {
    enum MockType: Identifiable, CaseIterable, Hashable {
        var id: Int { hashValue }
        case contract
        case implementation
        case tests
        case mock
    }
    enum MockSelectionType: Identifiable, CaseIterable, Hashable {
        var id: Int { hashValue }
        case contract
        case implementation
        case mock
    }


    static var previews: some View {
        DependencyView(title: "DependencyTitle",
                       onSelection: { },
                       onRemove: { },
                       allTypes: [
                        .init(title: "Contract",
                              subtitle: nil,
                              value: MockType.contract,
                              subValue: nil,
                              selectedValue: nil,
                              selectedSubValue: nil),
                        .init(title: "Implementation",
                              subtitle: "Tests",
                              value: .implementation,
                              subValue: .tests,
                              selectedValue: MockSelectionType.contract,
                              selectedSubValue: .mock),
                        .init(title: "Mock",
                              subtitle: nil,
                              value: MockType.mock,
                              subValue: nil,
                              selectedValue: nil,
                              selectedSubValue: nil),
                       ],
                       allSelectionValues: Array(MockSelectionType.allCases),
                       onUpdateTargetTypeValue: { _, _ in })
    }
}
