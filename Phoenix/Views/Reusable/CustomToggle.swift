import SwiftUI

struct CustomToggle: View {
    let title: String
    let isOnValue: Bool
    let whenTurnedOn: () -> Void
    let whenTurnedOff: () -> Void

    var body: some View {
        Toggle(isOn: Binding(get: { isOnValue },
                             set: { $0 ? whenTurnedOn() : whenTurnedOff() }),
               label: { Text(title) }
        )
    }
}

struct CustomToggle_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CustomToggle(title: "Contract",
                         isOnValue: true,
                         whenTurnedOn: {},
                         whenTurnedOff: {})
            CustomToggle(title: "Contract",
                         isOnValue: false,
                         whenTurnedOn: {},
                         whenTurnedOff: {})
        }
    }
}
