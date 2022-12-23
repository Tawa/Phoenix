import SwiftPackage
import SwiftUI

struct ExternalDependencyVersionView: View {
    @Binding var version: ExternalDependencyVersion
    
    // MARK: - Private
    private var versionPlaceholder: String {
        switch version {
        case .from, .exact:
            return "1.0.0"
        case .branch:
            return "main"
        }
    }
    
    private let allVersionsTypes: [IdentifiableWithTitle<ExternalDependencyVersion>] = [
        .init(title: "branch", value: ExternalDependencyVersion.branch(name: "main")),
        .init(title: "exact", value: ExternalDependencyVersion.exact(version: "1.0.0")),
        .init(title: "from", value: ExternalDependencyVersion.from(version: "1.0.0"))
    ]
    
    private var versionText: Binding<String> {
        .init {
            version.stringValue
        } set: { newValue in
            switch version {
            case .branch:
                version = .branch(name: newValue)
            case .exact:
                version = .exact(version: newValue)
            case .from:
                version = .from(version: newValue)
            }
        }
    }
    
    var body: some View {
        HStack {
            Menu {
                ForEach(allVersionsTypes) { versionType in
                    Button(versionType.title) { version = versionType.value }
                }
            } label: {
                Text(version.title)
            }
            .frame(width: 100)
            TextField(versionPlaceholder,
                      text: versionText)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            Spacer()
                .frame(maxWidth: .infinity)
        }
    }
}

struct ExternalDependencyVersionView_Previews: PreviewProvider {
    static var previews: some View {
        ExternalDependencyVersionView(version: .constant(.branch(name: "main")))
        ExternalDependencyVersionView(version: .constant(.exact(version: "1.0")))
    }
}
