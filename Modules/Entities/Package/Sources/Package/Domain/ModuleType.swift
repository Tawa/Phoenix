public enum ModuleType: Codable, Hashable {
    case contract
    case implementation
    case mock

}

public extension Array where Element == ModuleType {
    static var all: [ModuleType] { [.contract, .implementation, .mock] }
}
