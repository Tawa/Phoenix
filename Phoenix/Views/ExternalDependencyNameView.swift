import SwiftUI
import SwiftPackage

struct ExternalDependencyNameView: View {
    @Binding var name: ExternalDependencyName
    var onRemove: (() -> Void)? = nil

    // MARK: - Private
    private var nameText: Binding<String> {
        .init {
            name.name
        } set: { newValue in
            switch name {
            case .name:
                name = .name(newValue)
            case .product(_, let package):
                self.name = .product(name: newValue, package: package)
            }
        }
    }

    private var packageText: Binding<String?> {
        .init {
            name.package
        } set: { newValue in
            switch name {
            case .name:
                break
            case .product(let name, _):
                self.name = .product(name: name, package: newValue ?? "")
            }
        }
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Menu {
                    Button("Name") {
                        name = .name(name.name)
                    }
                    Button("Name/Package") {
                        name = .product(name: name.name, package: "")
                    }
                } label: {
                    switch name {
                    case .name:
                        Text("Name")
                    case .product:
                        Text("Name/Package")
                    }
                }
                .frame(width: 150)
                if let onRemove {
                    Button(action: onRemove) {
                        Image(systemName: "trash")
                    }
                }
            }
            switch name {
            case .name:
                TextField("Name", text: nameText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            case .product:
                TextField("Name", text: nameText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("Package", text: packageText.nonOptionalBinding)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
        }
    }
}

struct ExternalDependencyNameView_Previews: PreviewProvider {
    static var previews: some View {
        ExternalDependencyNameView(name: .constant(.name("Name")), onRemove: {})
        ExternalDependencyNameView(name: .constant(.product(name: "Name", package: "Package")), onRemove: {})
    }
}
