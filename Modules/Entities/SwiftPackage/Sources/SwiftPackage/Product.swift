public enum Product: Codable, Hashable, Comparable {
    case executable(Executable)
    case library(Library)

    public static func <(lhs: Product, rhs: Product) -> Bool {
        switch (lhs, rhs) {
        case (.executable(let lhsExecutable), .executable(let rhsExecutable)):
            return lhsExecutable < rhsExecutable
        case (.library(let lhsLibrary), .library(let rhsLibrary)):
            return lhsLibrary < rhsLibrary
        case (.executable, .library):
            return true
        case (.library, .executable):
            return false
        }
    }
}
