import SwiftUI

struct FamilyPopover: View {
    enum FocusFields: Hashable {
        case name
        case suffix
        case folder
    }

    @Binding var family: Family?
    @Binding var isPresenting: Bool

    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct FamilyPopover_Previews: PreviewProvider {
    static var previews: some View {
        FamilyPopover(
            family: .constant(Family(name: "DataStore",
                                     suffix: "DataStore",
                                     folder: "DataStores")),
            isPresenting: .constant(true))
    }
}
