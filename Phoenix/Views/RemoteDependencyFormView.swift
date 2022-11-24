import SwiftUI

enum ProductType: Identifiable, CaseIterable, Hashable {
    var id: Int { hashValue}
    case name
    case product

    var title: String {
        switch self {
        case .name:
            return "Name"
        case .product:
            return "Product"
        }
    }
}

enum VersionType: Identifiable, CaseIterable, Hashable {
    var id: Int { hashValue }
    case from
    case branch
    case exact

    var title: String {
        switch self {
        case .from:
            return "from"
        case .branch:
            return "branch"
        case .exact:
            return "exact"
        }
    }
}

struct RemoteDependencyFormResult {
    let urlString: String
    let versionType: VersionType
    let versionValue: String
    let productType: ProductType
    let productName: String
    let productPackage: String
}

struct RemoteDependencyFormView: View {

    private let title: String = "External Dependency:"
    private let urlTitle: String = "URL:"
    private let labelsWidth: CGFloat = 100

    @State private var urlString: String = ""
    @State private var versionString: String = ""
    @State private var name: String = ""
    @State private var package: String = ""

    @State private var productType: ProductType = .name
    @State private var versionType: VersionType = .from

    let onSubmit: (RemoteDependencyFormResult) -> Void
    let onDismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.title)

            HStack {
                HStack {
                    Text(urlTitle)
                    Spacer()
                }
                .frame(width: labelsWidth)
                TextField("ex: git@github.com:team/repo.git",
                          text: $urlString)
            }

            HStack {
                Menu {
                    ForEach(VersionType.allCases) { value in
                        Button(action: { versionType = value }, label: { Text(value.title) })
                    }
                } label: {
                    Text(versionType.title)
                }
                .frame(width: labelsWidth)

                TextField("1.0.0", text: $versionString)
            }


            HStack {
                Menu {
                    ForEach(ProductType.allCases) { value in
                        Button(action: { productType = value }, label: { Text(value.title) })
                    }
                } label: {
                    Text(productType.title)
                }
                .frame(width: labelsWidth)

                TextField("Name", text: $name)

                if case .product = productType {
                    TextField("Package", text: $package)
                }
            }

            HStack {
                Button(action: submit) {
                    Text("Add")
                }
                Button(action: onDismiss) { Text("Cancel") }
                    .keyboardShortcut(.cancelAction)
            }
        }.padding()
    }

    private func submit() {
        let result = RemoteDependencyFormResult(urlString: urlString,
                                                versionType: versionType,
                                                versionValue: versionString,
                                                productType: productType,
                                                productName: name,
                                                productPackage: package)
        onSubmit(result)
    }
}

struct RemoteDependencyFormView_Previews: PreviewProvider {
    static var previews: some View {
        RemoteDependencyFormView(onSubmit: { _ in },
                                 onDismiss: {})
    }
}
