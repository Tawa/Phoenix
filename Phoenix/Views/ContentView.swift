import SwiftUI
import ComposableArchitecture

struct ContentView: View {
    @Binding var document: PhoenixDocument
    let store: Store<FileStructure, AppAction>

    init(document: Binding<PhoenixDocument>) {
        self._document = document
        self.store = Store(initialState: document.wrappedValue.fileStructure,
                           reducer: appReducer,
                           environment: AppEnvironment())
    }

    var body: some View {
        WithViewStore(self.store) { viewStore in
            List {
                Text("Hello, World")

                ForEach(viewStore.components) { component in
                    VStack(alignment: .leading) {
                        Text(component.name.given)
                        Text(component.name.family)
                    }
                }

                Button {
                    viewStore.send(.addComponent)
                } label: {
                    Text("Add")
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(document: .constant(PhoenixDocument()))
    }
}
