import Component
import SwiftUI

struct RemoteComponentDependenciesSheet: View {
    
    let rows: [RemoteComponent]
    let onSelect: (RemoteComponent) -> Void
    let onDismiss: () -> Void
    
    @State private var filter: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            FilterView(text: $filter,
                       onSubmit: performSubmit)
            .padding(.top)
            List {
                ForEach(filteredRows) { row in
                    Button {
                        onSelect(row)
                    } label: {
                        Text(row.url)
                    }
                    .padding(.leading, 2)
                }
                Spacer()
            }
            .padding(.horizontal)
            .frame(minHeight: 400)
            Button(action: onDismiss) {
                Text("Cancel")
            }
            .keyboardShortcut(.cancelAction)
            .padding()
        }
        .frame(minWidth: 400)
    }
    
    // MARK: - Private
    private var filteredRows: [RemoteComponent] {
        rows.filtered(filter)
    }
    
    private func performSubmit() {
        let rows = filteredRows
        guard rows.count == 1 else { return }
        rows.first.map(onSelect)
    }
}

struct RemoteComponentDependenciesSheet_Previews: PreviewProvider {
    static var previews: some View {
        RemoteComponentDependenciesSheet(
            rows: [],
            onSelect: { _ in },
            onDismiss: {}
        )
    }
}
