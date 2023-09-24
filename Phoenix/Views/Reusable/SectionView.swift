import SwiftUI

struct SectionView<Content: View>: View {
    let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        Section {
            HStack(alignment: .center) {
                content()
            }
            Divider()
        }
    }
}
