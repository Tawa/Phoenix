import SwiftUI

struct LazySubmitTextField: View {

    @State private var value: String
    let placeholder: String
    let initialValue: String
    let onSubmit: (String) -> Void

    init(placeholder: String,
         initialValue: String,
         onSubmit: @escaping (String) -> Void) {
        value = initialValue
        self.placeholder = placeholder
        self.initialValue = initialValue
        self.onSubmit = onSubmit
    }

    var body: some View {
        TextField(placeholder, text: $value)
            .onSubmit {
                onSubmit(value)
            }
            .font(.largeTitle)
            .foregroundColor(value != initialValue ? .red : nil)
    }
}

struct LazySubmitTextField_Previews: PreviewProvider {
    static var previews: some View {
        LazySubmitTextField(
            placeholder: "1.0.0",
            initialValue: "",
            onSubmit: { _ in })
    }
}
