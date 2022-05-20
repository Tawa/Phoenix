import SwiftUI

struct FilterView: View {
    @Binding var filter: String
    var onExit: (() -> Void)? = nil

    var body: some View {
        HStack {
            TextField("Filter", text: $filter)
                .onExitCommand(perform: {
                    if filter.isEmpty {
                        onExit?()
                    } else {
                        filter = ""
                    }
                })
                .font(.title)
            if !filter.isEmpty {
                Button(action: { filter = "" }, label: {
                    Image(systemName: "clear.fill")
                })
                .aspectRatio(1, contentMode: .fit)
            }
        }.padding(16)
    }
}

struct FilterView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            FilterView(filter: .constant(""))
            FilterView(filter: .constant("DataStore"))
        }
    }
}
