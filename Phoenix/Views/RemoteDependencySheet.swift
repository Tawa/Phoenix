import SwiftUI

struct RemoteDependencySheet: View {
    let onExternalSubmit: (RemoteDependencyFormResult) -> Void
    let onDismiss: () -> Void

    var body: some View {
        ScrollView {
            RemoteDependencyFormView(onSubmit: onExternalSubmit,
                                     onDismiss: onDismiss)
        }
        .padding()
    }
}
