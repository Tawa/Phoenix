import SwiftUI

struct FilterView: View {
    @Binding var text: String
    var onSubmit: (() -> Void)? = nil
    
    init(text: Binding<String>,
         onSubmit: (() -> Void)? = nil) {
        _text = text
        self.onSubmit = onSubmit
    }
    
    var body: some View {
        HStack {
            TextField("Filter",
                      text: $text
            )
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .onSubmit {
                onSubmit?()
            }
            if text.isEmpty == false {
                Button(action: { text = "" }, label: {
                    Image(systemName: "clear.fill")
                })
                .aspectRatio(1, contentMode: .fit)
            }
        }.padding(16)
    }
}
