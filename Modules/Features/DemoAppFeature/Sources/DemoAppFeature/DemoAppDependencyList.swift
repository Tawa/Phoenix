import SwiftUI

struct DemoAppDependencySubrow: Identifiable {
    let id = UUID().uuidString
    let title: String
    let selected: Bool
    let onToggleSelection: (Bool) -> Void
}

struct DemoAppDependencyRow: Identifiable {
    let id = UUID().uuidString
    let title: String
    let subrows: [DemoAppDependencySubrow]
}

struct DemoAppDependencySection: Identifiable {
    let id = UUID().uuidString

    let title: String
    let rows: [DemoAppDependencyRow]
}

struct DemoAppDependencyList: View {
    let sections: [DemoAppDependencySection]
    
    var body: some View {
        List {
            ForEach(sections) { section in
                Section {
                    ForEach(section.rows) { row in
                        VStack(alignment: .leading, spacing: 0) {
                            Text(row.title)
                                .font(.title2.bold())
                            ForEach(row.subrows) { subrow in
                                Toggle(subrow.title,
                                       isOn: .init(get: { subrow.selected },
                                                   set: { subrow.onToggleSelection($0) }))
                            }
                        }
                    }
                } header: {
                    Text(section.title)
                        .font(.largeTitle.bold())
                }
                Divider()
            }
        }
    }
}

struct DemoAppDependencyList_Previews: PreviewProvider {
    static var previews: some View {
        DemoAppDependencyList(
            sections: [
                .init(title: "Core", rows: [
                    .init(title: "Repository", subrows: [
                        .init(title: "Contract", selected: true, onToggleSelection: { _ in }),
                        .init(title: "Implementation", selected: true, onToggleSelection: { _ in }),
                        .init(title: "Mock", selected: true, onToggleSelection: { _ in }),
                    ])
                ])
            ]
        ).frame(width: 400)
    }
}
