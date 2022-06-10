import SwiftUI

struct DynamicTextFieldList<MenuOption, TargetType>: View
where MenuOption: RawRepresentable & CaseIterable & Hashable & Identifiable,
      TargetType: Hashable & Identifiable {
    struct ValueContainer: Hashable, Identifiable {
        let id: String
        var value: String
        var menuOption: MenuOption
        var targetTypes: [TargetType]
    }

    @State private var textValues: [String: String] = [:]
    @State private var newFieldValue: String = ""
    @Binding var values: [ValueContainer]
    let allTargetTypes: [IdentifiableWithSubtype<TargetType>]
    let onRemoveValue: (String) -> Void
    let onNewValue: (String) -> Void

    var body: some View {
        VStack(alignment: .leading) {
            ForEach($values, id: \.self) { value in
                VStack(alignment: .leading) {
                    HStack {
                        CustomMenu(title: String(describing: value.menuOption.wrappedValue.rawValue),
                                   data: Array(MenuOption.allCases),
                                   onSelection: { value.wrappedValue.menuOption = $0 },
                                   hasRemove: false,
                                   onRemove: {})
                        .frame(width: 150)
                        TextField("Folder Name", text: Binding(get: { value.value.wrappedValue }, set: { textValues[value.id] = $0 }))
                            .font(.largeTitle)
                            .frame(width: 150)
                            .foregroundColor(value.wrappedValue.value == textValues[value.id] ? nil : .red)
                            .onSubmit { value.wrappedValue.value = textValues[value.id] ?? "" }
                        Button(action: {
                            onRemoveValue(value.id)
                        }) {
                            Text("Remove")
                        }
                    }

                    ForEach(allTargetTypes) { targetType in
                        HStack {
                            CustomToggle(title: targetType.title,
                                         isOnValue: value.targetTypes.wrappedValue.contains(targetType.value),
                                         whenTurnedOn: { value.targetTypes.wrappedValue.append(targetType.value) },
                                         whenTurnedOff: { value.targetTypes.wrappedValue.removeAll(where: { $0 == targetType.value }) })
                            if let subtitle = targetType.subtitle, let subvalue = targetType.subValue {
                                CustomToggle(title: subtitle,
                                             isOnValue: value.targetTypes.wrappedValue.contains(subvalue),
                                             whenTurnedOn: { value.targetTypes.wrappedValue.append(subvalue) },
                                             whenTurnedOff: { value.targetTypes.wrappedValue.removeAll(where: { $0 == subvalue }) })
                            }
                            Spacer()
                        }
                    }
                }
            }
            HStack {
                TextField("New",
                          text: $newFieldValue)
                .font(.largeTitle)
                Button(action: {
                    onNewValue(newFieldValue)
                    newFieldValue = ""
                }) {
                    Text("Add")
                }
            }
        }
        .onChange(of: values, perform: refreshTextValues(with:))
        .onAppear {
            refreshTextValues(with: $values.wrappedValue)
        }
    }

    private func refreshTextValues(with values: [ValueContainer]) {
        let result = values.reduce(into: [String: String](), { partialResult, container in
            partialResult[container.id] = container.value
        })

        textValues = result
    }
}

struct DynamicTextFieldList_Previews: PreviewProvider {
    enum Options: String, Hashable, CaseIterable, Identifiable {
        var id: Int { hashValue }
        case copy
        case process
    }

    enum TargetType: Hashable, Identifiable {
        var id: Int { hashValue }
        case contract
        case implementation
        case tests
        case mock
    }

    static var previews: some View {
        Group {
            DynamicTextFieldList(values: .constant([.init(id: "ID1",
                                                          value: "Folder",
                                                          menuOption: Options.process,
                                                          targetTypes: [])]),
                                 allTargetTypes: [
                                    .init(title: "First", subtitle: nil, value: TargetType.contract, subValue: nil),
                                    .init(title: "Second", subtitle: "Tests",
                                          value: .implementation, subValue: .tests),
                                    .init(title: "Third", subtitle: nil, value: .mock, subValue: nil)
                                 ],
                                 onRemoveValue: { _ in },
                                 onNewValue: { _ in })
        }
    }
}
