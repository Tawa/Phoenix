import SwiftUI

struct ComponentListItem: View {
    let name: String
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        ZStack {
            if isSelected {
                Color.gray
            }
            HStack {
                Text(name)
                    .font(.headline.bold())
                    .foregroundColor(isSelected ? Color.white : nil)
                    .padding(8)
                Spacer()
            }
        }
        .frame(height: 40)
        .cornerRadius(8)
        .contentShape(RoundedRectangle(cornerRadius: 8))
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
