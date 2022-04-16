import Package
import SwiftUI

struct ModuleSectionView: View {
    let title: String
    @Binding var moduleDescription: ModuleDescription?

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Toggle(isOn: Binding(
                    get: { moduleDescription != nil },
                    set: { isOn in
                        if isOn {
                            moduleDescription = ModuleDescription(dependencies: [],
                                                                  hasTests: false,
                                                                  testsDependencies: [])
                        } else {
                            moduleDescription = nil
                        }
                    })) {
                        Text(title)
                            .font(.title)
                    }
                Spacer()
            }
            if moduleDescription != nil {
                ModuleView(moduleDescription: Binding(
                    get: { moduleDescription! },
                    set: { moduleDescription = $0 }))
            }

        }
        .padding()
        .frame(maxWidth: .infinity)
        .border(Color.gray, width: 1)
    }
}

struct ModuleSectionView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ModuleSectionView(title: "Contract", moduleDescription: .constant(.init(dependencies: [],
                                                                                    hasTests: false,
                                                                                    testsDependencies: [])))
            ModuleSectionView(title: "Implementation", moduleDescription: .constant(.init(dependencies: [.module(Name(given: "Wordpress",
                                                                                                                      family: "Repository"),
                                                                                                                 type: .contract)],
                                                                                    hasTests: true,
                                                                                          testsDependencies: [.module(Name(given: "Wordpress",
                                                                                                                           family: "Repository"),
                                                                                                                      type: .implementation)])))
        }
    }
}
