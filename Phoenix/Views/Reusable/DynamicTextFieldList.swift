import SwiftUI
import Package

struct DynamicTextFieldList<MenuOption>: View where MenuOption: RawRepresentable & CaseIterable & Hashable & Identifiable {
    struct ValueContainer: Hashable, Identifiable {
        let id: String
        var value: String
        var menuOption: MenuOption
        var targetTypes: [TargetType]
    }

    @State private var textValues: [String: String] = [:]
    @State private var newFieldValue: String = ""
    @Binding var values: [ValueContainer]
    let onRemoveValue: (String) -> Void
    let onNewValue: (String) -> Void

    var body: some View {
        VStack {
            ForEach($values, id: \.self) { value in
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
                    CustomToggle(title: "Contract",
                                 isOnValue: value.targetTypes.wrappedValue.contains(.contract),
                                 whenTurnedOn: { value.targetTypes.wrappedValue.append(.contract) },
                                 whenTurnedOff: { value.targetTypes.wrappedValue.removeAll(where: { $0 == .contract }) })
                    VStack(alignment: .leading) {
                        CustomToggle(title: "Implementation",
                                     isOnValue: value.targetTypes.wrappedValue.contains(.implementation),
                                     whenTurnedOn: { value.targetTypes.wrappedValue.append(.implementation) },
                                     whenTurnedOff: { value.targetTypes.wrappedValue.removeAll(where: { $0 == .implementation }) })
                        CustomToggle(title: "Tests",
                                     isOnValue: value.targetTypes.wrappedValue.contains(.tests),
                                     whenTurnedOn: { value.targetTypes.wrappedValue.append(.tests) },
                                     whenTurnedOff: { value.targetTypes.wrappedValue.removeAll(where: { $0 == .tests }) })
                    }
                    CustomToggle(title: "Mock",
                                 isOnValue: value.targetTypes.wrappedValue.contains(.mock),
                                 whenTurnedOn: { value.targetTypes.wrappedValue.append(.mock) },
                                 whenTurnedOff: { value.targetTypes.wrappedValue.removeAll(where: { $0 == .mock }) })
                    Spacer()
                    Button(action: {
                        onRemoveValue(value.id)
                    }) {
                        Text("Remove")
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

    static var previews: some View {
        Group {
            DynamicTextFieldList(values: .constant([.init(id: "ID1",
                                                          value: "Folder",
                                                          menuOption: Options.process,
                                                         targetTypes: [])]),
                                 onRemoveValue: { _ in },
                                 onNewValue: { _ in })
        }
    }
}
