import Package
import SwiftUI

struct ComponentModuleTypeView: View {
    let title: String
    let isOn: Bool
    let onOn: () -> Void
    let onOff: () -> Void
    let selectionTitle: String
    let onSelection: (LibraryType) -> Void
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
                               data: LibraryType.allCases,
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
    static var previews: some View {
        Group {
            ComponentModuleTypeView(title: "Contract",
                                    isOn: false,
                                    onOn: {},
                                    onOff: {},
                                    selectionTitle: "undefined",
                                    onSelection: { _ in },
                                    onRemove: {})
            ComponentModuleTypeView(title: "Contract",
                                    isOn: true,
                                    onOn: {},
                                    onOff: {},
                                    selectionTitle: "undefined",
                                    onSelection: { _ in },
                                    onRemove: {})
            ComponentModuleTypeView(title: "Contract",
                                    isOn: true,
                                    onOn: {},
                                    onOff: {},
                                    selectionTitle: "dynamic",
                                    onSelection: { _ in },
                                    onRemove: {})
        }.frame(height: 50)
    }
}
