import SwiftUI

struct ComponentListItem: View {
    let name: String
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            ZStack(alignment: .leading) {
                isSelected ? Color.accentColor : Color.clear
                Text(name)
                    .foregroundColor(isSelected ? Color.white : nil)
                    .padding(8)
            }
            .contentShape(Rectangle())
            .cornerRadius(8)
        }.buttonStyle(.plain)
    }
}

struct ComponentListItem_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ComponentListItem(name: "WordpressRepository",
                              isSelected: true,
                              onSelect: {})
            ComponentListItem(name: "WordpressRepository",
                              isSelected: false,
                              onSelect: {})
        }
    }
}
