import PhoenixDocument
import SwiftUI

struct MacroComponentView: View {
    @Binding var macroComponent: MacroComponent
    let onRemove: () -> Void
    
    var body: some View {
        List {
            headerView()
        }
    }
    
    @ViewBuilder private func headerView() -> some View {
        section {
            Text(macroComponent.name)
                .font(.largeTitle.bold())
            Spacer()
            Button(role: .destructive, action: onRemove) {
                Image(systemName: "trash")
            }.help("Remove")
        }
    }
    
    // MARK: - Helper Functions
    @ViewBuilder private func section<Content: View>(@ViewBuilder content: @escaping () -> Content) -> some View {
        Section {
            HStack(alignment: .center) {
                content()
            }
            Divider()
        }
    }
}
