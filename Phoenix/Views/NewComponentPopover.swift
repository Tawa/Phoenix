import Package
import SwiftUI

struct NewComponentPopover: View {
    @State private var name: String = ""
    @State private var familyName: String = ""

    let onSubmit: (Name) -> Void

    var body: some View {
        VStack {
            VStack(spacing: 0) {
                TextField("Given Name", text: $name)
                    .font(.largeTitle)
                TextField("Family Name", text: $familyName)
                    .font(.largeTitle)
            }.padding()
            Button {
                let name = Name(given: name, family: familyName)
                onSubmit(name)
            } label: {
                Text("Add")
            }

        }
        .frame(maxWidth:  .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.9))
    }
}

struct NewComponentPopover_Previews: PreviewProvider {
    static var previews: some View {
        NewComponentPopover(onSubmit: { _ in })
    }
}
