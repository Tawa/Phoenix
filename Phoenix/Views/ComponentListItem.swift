import SwiftUI

struct ComponentListItem: View {
    let name: String
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        ZStack(alignment: .leading) {
            isSelected ? Color.gray : Color.clear
            Text(name)
                .font(.title2)
                .foregroundColor(isSelected ? Color.white : nil)
                .padding(8)
        }
        .contentShape(Rectangle())
        .cornerRadius(8)
        .onTapGesture(perform: onSelect)
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
