import SwiftUI

struct CustomMenu<Data>: View where Data: Identifiable {
    let title: String
    let data: [Data]
    let onSelection: (Data) -> Void
    let hasRemove: Bool
    let onRemove: () -> Void

    var body: some View {
        Menu(title) {
            ForEach(data) { value in
                Button(action: { onSelection(value) }) {
                    Text("\(String(describing: value))")
                }
            }
            Divider()
            if hasRemove {
                Button(action: onRemove) {
                    Text("Remove")
                }
            }
        }
        .frame(width: 150)
    }
}
