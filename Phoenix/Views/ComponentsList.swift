import Package
import SwiftUI

struct ComponentsList: View {
    @Binding var components: [Component]
    @Binding var selectedIndex: Int
    let onAddButton: () -> Void

    var body: some View {
        List {
            ForEach(components.enumeratedArray(), id: \.element) { index, component in
                ZStack {
                    if selectedIndex == index {
                        Color.gray
                    }
                    HStack {
                        Text(component.name.given + component.name.family)
                            .font(.headline.bold())
                            .foregroundColor(selectedIndex == index ? Color.white : nil)
                            .padding(4)
                        Spacer()
                    }
                }
                .contentShape(RoundedRectangle(cornerRadius: 8))
                .onTapGesture(perform: { selectedIndex = index })
            }

            if components.isEmpty {
                Text("0 components")
                    .foregroundColor(.gray)
            }
            Button(action: onAddButton) {
                Text("Add")
            }
        }
    }
}

struct ComponentsList_Previews: PreviewProvider {
    struct Preview: View {
        @State var components: [Component] = []
        @State var selectedIndex: Int = 0

        var body: some View {
            ComponentsList(components: $components,
                           selectedIndex: $selectedIndex,
                           onAddButton: {})
        }
    }

    static var previews: some View {
        Preview()
    }
}
