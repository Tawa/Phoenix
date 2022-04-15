import Package
import SwiftUI

struct ComponentView: View {
    @Binding var component: Component?

    var body: some View {
        VStack {
            if let component = component {
                HStack {
                    Text(component.name.full)
                        .font(.largeTitle)
                        .multilineTextAlignment(.leading)
                    Spacer()
                }
                HStack {
                    Text("Platforms:")
                    Menu(iOSPlatformMenuTitle) {
                        ForEach(iOSVersion.allCases) { version in
                            Button(action: { self.component?.iOSVersion = version }) {
                                Text("\(String(describing: version))")
                            }
                        }
                        if component.iOSVersion != nil {
                            Button(action: { self.component?.iOSVersion = nil }) {
                                Text("Remove")
                            }
                        }
                    }.frame(width: 150)
                    Menu(macOSPlatformMenuTitle) {
                        ForEach(macOSVersion.allCases) { version in
                            Button(action: { self.component?.macOSVersion = version }) {
                                Text("\(String(describing: version))")
                            }
                        }
                        if component.macOSVersion != nil {
                            Button(action: { self.component?.macOSVersion = nil }) {
                                Text("Remove")
                            }
                        }
                    }.frame(width: 150)
                    Spacer()
                }

            } else {
                HStack {
                    Text("No Component Selected")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                    Spacer()
                }
            }
            Spacer()
        }
        .padding()
    }

    private var iOSPlatformMenuTitle: String {
        if let iOSVersion = component?.iOSVersion {
            return ".iOS(.\(iOSVersion))"
        } else {
            return "Add iOS"
        }
    }

    private var macOSPlatformMenuTitle: String {
        if let macOSVersion = component?.macOSVersion {
            return ".macOS(.\(macOSVersion))"
        } else {
            return "Add macOS"
        }
    }
}

struct ComponentView_Previews: PreviewProvider {
    struct Preview: View {
        @State var component: Component? = Component(name: Name(given: "Wordpress", family: "Repository"),
                                                     iOSVersion: .v13,
                                                     macOSVersion: .v12,
                                                     types: [:])

        var body: some View {
            ComponentView(component: $component)
        }
    }

    static var previews: some View {
        Preview()
    }
}
