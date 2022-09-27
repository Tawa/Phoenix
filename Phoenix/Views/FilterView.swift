import SwiftUI

enum FilterType{
    case usageHierarchy
    case text
    var rawValue: String {
        switch self{
        case .usageHierarchy: return "Usage Hierarchy"
        case .text: return "Text"
        }
    }
}

struct FilterView: View {
    @Binding var filter: String
    @Binding var filterType: FilterType?
    var onSubmit: (() -> Void)? = nil
    
    private let cornerRadius = 4.0
    private let strokeWidth = 3.0
    private let padding = 8.0
    private let frameHeight = 32.0
    @FocusState private var focusState: Bool
    
    var body: some View {
        VStack {
            filterView()
            ZStack {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(focusState ? .quaternary : .secondary)
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        focusState ? .blue : .secondary,
                        lineWidth: focusState ? strokeWidth : 0.5
                    )
                    .scaleEffect(focusState ? 1.01 : 1)
                    .animation(
                        .linear(duration: 0.1).delay(0.05),
                        value: focusState
                    )
                textFieldView()
                
            }
            .frame(height: frameHeight)
        }.padding(padding)
    }
    
    @ViewBuilder
    func textFieldView() -> some View {
        HStack {
            Image(systemName: "magnifyingglass")
            TextField("Filter", text: $filter)
                .textFieldStyle(.plain)
                .focused($focusState)
            if !filter.isEmpty {
                Button(
                    action: { filter.removeAll() },
                    label: {
                        Image(systemName: "xmark.circle.fill")
                    }
                ).buttonStyle(.borderless)
            }
        }.padding(padding)
    }
    
    @ViewBuilder
    func filterView() -> some View {
        HStack {
            Menu {
                Button {
                    filterType = .text
                } label: {
                    Text("Text")
                }
                Button {
                    filterType = .usageHierarchy
                } label: {
                    Text("Usage Hierarchy")
                }
            } label: {
                Text(filterType?.rawValue ?? "")
            }
            .menuStyle(.borderlessButton)
            .menuIndicator(.hidden)
            
        }
    }
}

struct FilterView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            FilterView(
                filter: .constant("DataStore"),
                filterType: .constant(.text)
            )
        }
    }
}
