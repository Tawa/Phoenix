import Package
import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var viewModel: ViewModel
    @EnvironmentObject private var store: PhoenixDocumentStore

    var body: some View {
        ZStack {
            HSplitView {
                ComponentsList()
                    .frame(minWidth: 250)

                if let selectedComponent = store.selectedComponent {
                    ComponentView(component: selectedComponent,
                                  showingDependencyPopover: $viewModel.showingDependencyPopover)
                    .frame(minWidth: 750)
                } else {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading) {
                            Text("No Component Selected")
                                .font(.title)
                                .padding()
                            Spacer()
                        }
                        Spacer()
                    }.frame(minWidth: 750)
                }
            }

            if let family = store.selectedFamily {
                FamilyPopover(family: family)
            }

            if viewModel.showingDependencyPopover {
                ComponentDependenciesPopover(showingPopup: $viewModel.showingDependencyPopover)
            }

            if viewModel.showingNewComponentPopup {
                NewComponentPopover(isPresenting: $viewModel.showingNewComponentPopup)
            }

        }.toolbar {
//            Button(action: viewModel.onAddAll, label: { Text("Add everything in the universe") })
            Button(action: viewModel.onAddButton, label: { Text("Add New Component") })
                .keyboardShortcut("A", modifiers: [.command, .shift])
            Button(action: viewModel.onGenerate, label: { Text("Generate Packages") })
                .keyboardShortcut(.init("R"), modifiers: .command)
        }
    }
}
