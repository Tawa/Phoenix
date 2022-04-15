import Package
import SwiftUI

struct ComponentView: View {
    @Binding var component: Component

    var body: some View {
        VStack {
            Text(component.name.full)
                .font(.largeTitle)
            Menu(iOSPlatformMenuTitle) {

            }
        }
    }

    private var iOSPlatformMenuTitle: String {
        return "Add iOS"
    }
}

struct ComponentView_Previews: PreviewProvider {
    struct Preview: View {
        @State var component: Component = Component(name: Name(given: "Wordpress", family: "Repository"),
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
