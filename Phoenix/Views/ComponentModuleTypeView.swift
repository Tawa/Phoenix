import SwiftUI

struct ComponentModuleTypeView<Data>: View where Data: Identifiable {
    let title: String
    let isOn: Bool
    let onOn: () -> Void
    let onOff: () -> Void
    let selectionData: [Data]
    let selectionTitle: String
    let onSelection: (Data) -> Void
    let onRemove: () -> Void

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                CustomToggle(title: title,
                             isOnValue: isOn,
                             whenTurnedOn: onOn,
                             whenTurnedOff: onOff)

                if isOn {
                    CustomMenu(title: selectionTitle,
                               data: selectionData,
                               onSelection: onSelection,
                               hasRemove: false,
                               onRemove: onRemove)
                }
                Spacer()
            }
            Spacer()
        }
        .frame(width: 150)
    }
}

struct ComponentModuleTypeView_Previews: PreviewProvider {
    enum MockType: Identifiable, CaseIterable, Hashable {
        var id: Int { hashValue }
        case first
        case second
        case third
    }

    static var previews: some View {
        Group {
            ComponentModuleTypeView(title: "Package Type",
                                    isOn: false,
                                    onOn: {},
                                    onOff: {},
                                    selectionData: MockType.allCases,
                                    selectionTitle: "undefined",
                                    onSelection: { _ in },
                                    onRemove: {})
            ComponentModuleTypeView(title: "Package Type",
                                    isOn: true,
                                    onOn: {},
                                    onOff: {},
                                    selectionData: MockType.allCases,
                                    selectionTitle: "undefined",
                                    onSelection: { _ in },
                                    onRemove: {})
            ComponentModuleTypeView(title: "Package Type",
                                    isOn: true,
                                    onOn: {},
                                    onOff: {},
                                    selectionData: MockType.allCases,
                                    selectionTitle: "dynamic",
                                    onSelection: { _ in },
                                    onRemove: {})
        }.frame(height: 50)
    }
}
