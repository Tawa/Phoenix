import SwiftUI

struct DemoAppDependencyList: View {
    let dependencies: [DemoAppDependencyViewModel]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                ForEach(dependencies) { dependency in
                    VStack(alignment: .leading) {
                        HStack {
                            Text(dependency.title)
                                .font(.title2.bold())
                            Spacer()
                        }
                        ForEach(dependency.targetTypesSelected) { targetType in
                            Toggle(targetType.targetType, isOn: .constant(targetType.isSelected))
                        }
                    }.padding()
                }
            }
        }
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        DemoAppDependencyList(
            dependencies: [
                .init(title: "HomeRepository",
                      targetTypesSelected: [
                        .init(targetType: "Contract", isSelected: true),
                        .init(targetType: "Implementation", isSelected: true),
                        .init(targetType: "Mock", isSelected: true)
                      ])
            ]
        ).frame(width: 400)
    }
}
