import AccessibilityIdentifiers
import Component
import SwiftUI

struct MentionsView: View {
    @Binding var showing: Bool
    let mentions: [Name]
    let title: String
    let titleForComponentNamed: (Name) -> String
    let onSelectComponentName: (Name) -> Void
    var alignment: HorizontalAlignment = .trailing

    var body: some View {
        VStack(alignment: alignment) {
            HStack {
                Text("Mentions")
                Image(systemName: "info.circle")
                    .help("This is the list of components that depend on \(title).")
            }
            .contentShape(Rectangle())
            .with(accessibilityIdentifier: ComponentIdentifiers.mentionsButton)
            if showing {
                if mentions.isEmpty {
                    Text("\(title) is not used in any other component.")
                } else {
                    ForEach(mentions, id: \.self) { name in
                        Button {
                            onSelectComponentName(name)
                        } label: {
                            Text(titleForComponentNamed(name))
                        }
                    }
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .onHover { didEnter in
            withAnimation(.easeOut(duration: 0.2)) {
                showing = didEnter
            }
        }
    }
}
