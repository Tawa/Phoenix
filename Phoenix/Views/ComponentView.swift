import Package
import SwiftUI

struct ComponentView: View {
    @Binding var component: Component?

    var body: some View {
        HStack {
            VStack {
                if let component = component {
                    Text(component.name.full)
                        .font(.largeTitle)
                        .multilineTextAlignment(.leading)
                    HStack {
                        Text("Platforms:")
                        Menu(iOSPlatformMenuTitle) {

                        }
                        Menu(macOSPlatformMenuTitle) {

                        }
                    }

                } else {
                    Text("No Component Selected")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                }
                Spacer()
            }.padding()
            Spacer()
        }
    }

    private var iOSPlatformMenuTitle: String {
        return "Add iOS"
    }

    private var macOSPlatformMenuTitle: String {
        return "Add macOS"
    }
}

struct ComponentView_Previews: PreviewProvider {
    struct Preview: View {
        @State var component: Component? = Component(name: Name(given: "Wordpress", family: "Repository"),
                                                     platforms: [],
                                                     types: [:])

        var body: some View {
            ComponentView(component: $component)
        }
    }

    static var previews: some View {
        Preview()
    }
}
