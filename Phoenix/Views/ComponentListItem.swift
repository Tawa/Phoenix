import SwiftUI

struct ComponentListItem: View {
    let name: String
    let isSelected: Bool
    let onSelect: () -> Void
    let onDuplicate: () -> Void

    var body: some View {
        Button(action: onSelect) {
            ZStack(alignment: .leading) {
                isSelected ? Color.accentColor : Color.clear
                Text(name)
                    .foregroundColor(Color.white)
                    .padding(8)
            }
            .contentShape(Rectangle())
            .cornerRadius(8)
            .contextMenu {
                Button(action: onDuplicate) {
                    Text("Duplicate")
                }
            }
        }.buttonStyle(.plain)
    }
}

struct ComponentListItem_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ComponentListItem(name: "WordpressRepository",
                              isSelected: true,
                              onSelect: {},
                              onDuplicate: {})
            ComponentListItem(name: "WordpressRepository",
                              isSelected: false,
                              onSelect: {},
                              onDuplicate: {})
        }
    }
}
