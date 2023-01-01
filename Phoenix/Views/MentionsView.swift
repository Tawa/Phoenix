import AccessibilityIdentifiers
import Component
import SwiftUI

struct MentionsView: View {
    let mentions: [Name]
    let title: String
    let titleForComponentNamed: (Name) -> String
    let onSelectComponentName: (Name) -> Void
    
    var body: some View {
        ScrollView {
            HStack {
                VStack(alignment: .leading) {
                    HStack {
                        Text("Mentions")
                        Image(systemName: "info.circle")
                            .help("This is the list of components that depend on \(title).")
                    }
                    if mentions.isEmpty {
                        Text("\(title) is not used in any other component.")
                            .padding(.vertical)
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
                Spacer()
            }
            .padding()
        }
        .listStyle(BorderedListStyle())
    }
}
