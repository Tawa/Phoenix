public enum Product: Codable, Hashable, Comparable {
    case library(Library)

    public static func <(lhs: Product, rhs: Product) -> Bool {
        switch (lhs, rhs) {
        case (.library(let lhsLibrary), .library(let rhsLibrary)):
            return lhsLibrary < rhsLibrary
        }
    }
}
