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

#if DEBUG
import Package

struct ComponentModuleTypeView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ComponentModuleTypeView(title: "Contract",
                                    isOn: false,
                                    onOn: {},
                                    onOff: {},
                                    selectionData: LibraryType.allCases,
                                    selectionTitle: "undefined",
                                    onSelection: { _ in },
                                    onRemove: {})
            ComponentModuleTypeView(title: "Contract",
                                    isOn: true,
                                    onOn: {},
                                    onOff: {},
                                    selectionData: LibraryType.allCases,
                                    selectionTitle: "undefined",
                                    onSelection: { _ in },
                                    onRemove: {})
            ComponentModuleTypeView(title: "Contract",
                                    isOn: true,
                                    onOn: {},
                                    onOff: {},
                                    selectionData: LibraryType.allCases,
                                    selectionTitle: "dynamic",
                                    onSelection: { _ in },
                                    onRemove: {})
        }.frame(height: 50)
    }
}

#endif
