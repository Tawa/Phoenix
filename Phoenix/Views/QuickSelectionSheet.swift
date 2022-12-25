import SwiftUI

struct QuickSelectionRow: Identifiable {
    let id = UUID().uuidString
    let text: String
    let terms: [String]
    let onSelect: () -> Void
}

struct QuickSelectionSheet: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State private var filter: String = ""
    let rows: [QuickSelectionRow]
    @State var selectionIndex: Int = 0
    @State var filteredRows: [QuickSelectionRow] = []
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Button(action: onUpArrow, label: {})
                    .opacity(0)
                    .keyboardShortcut(.upArrow, modifiers: [])
                Button(action: onDownArrow, label: {})
                    .opacity(0)
                    .keyboardShortcut(.downArrow, modifiers: [])
                HStack(spacing: 0) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                        .padding()
                    TextField("Open Quickly", text: $filter)
                        .textFieldStyle(.plain)
                        .padding([.trailing, .top, .bottom])
                        .font(.title2)
                        .onChange(of: filter, perform: { _ in
                            refreshRows()
                        })
                        .onSubmit(performSelection)
                    if !filter.isEmpty {
                        Button {
                            filter = ""
                        } label: {
                            Image(systemName: "multiply.circle.fill")
                                .padding()
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            ScrollViewReader { proxy in
                ScrollView {
                    ForEach(0..<filteredRows.count, id: \.self) { index in
                        Button(action: filteredRows[index].onSelect) {
                            ZStack(alignment: .leading) {
                                index == selectionIndex ? Color.accentColor : Color.clear
                                Text(filteredRows[index].text)
                                    .foregroundColor(index == selectionIndex ? Color.white : nil)
                                    .padding(8)
                            }
                            .contentShape(Rectangle())
                            .cornerRadius(8)
                        }.buttonStyle(.plain)
                    }
                    .padding()
                }
                .onChange(of: selectionIndex) { newValue in
                    proxy.scrollTo(selectionIndex)
                }
                .frame(minHeight: 400)
            }
        }
        .frame(minWidth: 400)
        .background(.ultraThinMaterial)
    }
    
    // MARK: - Private
    private func refreshRows() {
        filteredRows = {
            guard !filter.isEmpty else { return [] }
            let filter = filter.lowercased()
            let pattern = filter.map(String.init).joined(separator: ".*")
            do {
                let regex = try NSRegularExpression(pattern: pattern)
                return rows.filter { row in
                    row.terms.contains { term in
                        !regex.matches(in: term, options: [], range: NSRange(location: 0, length: term.utf16.count)).isEmpty
                    }
                }
            } catch {
                return rows.filter { row in
                    row.terms.contains { term in
                        term.contains(filter)
                    }
                }
            }
        }()
        if selectionIndex > filteredRows.count - 1 {
            selectionIndex = 0
        }
    }
    
    private func performSelection() {
        guard selectionIndex < filteredRows.count else { return }
        filteredRows[selectionIndex].onSelect()
        presentationMode.wrappedValue.dismiss()
    }
    
    private func onUpArrow() {
        guard selectionIndex > 0 else { return }
        selectionIndex -= 1
    }
    
    private func onDownArrow() {
        guard selectionIndex < filteredRows.count - 1 else { return }
        selectionIndex += 1
    }
}

struct QuickSelectionSheet_Previews: PreviewProvider {
    static var previews: some View {
        QuickSelectionSheet(
            rows: [
                .init(text: "HomeFeature",
                      terms: ["HomeFeature"],
                      onSelect: {}),
                .init(text: "HomeUseCases",
                      terms: ["HomeUseCases"],
                      onSelect: {}),
                .init(text: "HomeRepository",
                      terms: ["HomeRepository"],
                      onSelect: {})
            ]
        )
    }
}
