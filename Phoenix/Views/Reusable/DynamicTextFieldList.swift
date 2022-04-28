import SwiftUI
import Package

struct DynamicTextFieldList<MenuOption>: View where MenuOption: RawRepresentable & CaseIterable & Hashable & Identifiable {
    struct ValueContainer: Hashable, Identifiable {
        let id: String
        var value: String
        var menuOption: MenuOption
        var targetTypes: [TargetType]
    }

    @State private var newFieldValue: String = ""
    @Binding var values: [ValueContainer]
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
                    TextField("Folder Name", text: value.value)
                        .font(.largeTitle)
                        .id(value.id)
                        .frame(width: 150)
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
                                 onNewValue: { _ in })
        }
    }
}
