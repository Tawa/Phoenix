import AccessibilityIdentifiers
import SwiftUI

struct DependencyModuleTypeSelectorView<DataType>: View where DataType: Hashable {
    let title: String
    let dependencyName: String

    let value: DataType?
    let allValues: [DataType]
    let onValueChange: (DataType?) -> Void

    var body: some View {
        if allValues.count == 1 {
            Toggle(title,
                   isOn: .init(get: { value != nil },
                               set: { onValueChange($0 ? allValues[0] : nil) }))
        } else {
            HStack {
                Text(title)
                Image(systemName: "arrow.right")
                Menu(content: {
                    ForEach(allValues, id: \.self) { type in
                        Button(String(describing: type), action: { onValueChange(type) })
                            .with(accessibilityIdentifier: DependencyViewIdentifiers.option(dependencyName: dependencyName,
                                                                                            packageName: title,
                                                                                            option: String(describing: type)))
                    }
                    if value != nil {
                        Divider()
                        Button(action: { onValueChange(nil) }, label: { Text("Remove") })
                            .with(accessibilityIdentifier: DependencyViewIdentifiers.removeOption(
                                dependencyName: dependencyName,
                                packageName: title))
                    }
                }, label: {
                    Text(value.map { String(describing:$0) } ?? "Add")
                })
                .with(accessibilityIdentifier: DependencyViewIdentifiers.menu(
                    dependencyName: dependencyName,
                    packageName: title))
                .frame(width: 150)
            }
        }
    }
}

struct DependencyView<TargetType, SelectionType>: View
where TargetType: Identifiable, SelectionType: Hashable {
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
                    .font(.largeTitle.bold())
                Button(action: onSelection) { Text("Jump to") }
                Button(action: onRemove) { Text("Remove") }
            }
            .padding(.bottom)
            VStack {
                ForEach(allTypes) { dependencyType in
                    HStack {
                        DependencyModuleTypeSelectorView<SelectionType>(
                            title: dependencyType.title,
                            dependencyName: title,
                            value: dependencyType.selectedValue,
                            allValues: allSelectionValues,
                            onValueChange: { onUpdateTargetTypeValue(dependencyType.value, $0) })

                        if let subtitle = dependencyType.subtitle,
                           let subvalue = dependencyType.subValue {
                            Divider()
                            DependencyModuleTypeSelectorView<SelectionType>(
                                title: subtitle,
                                dependencyName: title,
                                value: dependencyType.selectedSubValue,
                                allValues: allSelectionValues,
                                onValueChange: { onUpdateTargetTypeValue(subvalue, $0) })
                        }
                        Spacer()
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
                        .init(title: "First",
                              subtitle: nil,
                              value: MockType.contract,
                              subValue: nil,
                              selectedValue: nil,
                              selectedSubValue: nil),
                        .init(title: "Second",
                              subtitle: "Tests",
                              value: .implementation,
                              subValue: .tests,
                              selectedValue: MockSelectionType.contract,
                              selectedSubValue: .mock),
                        .init(title: "Third",
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
