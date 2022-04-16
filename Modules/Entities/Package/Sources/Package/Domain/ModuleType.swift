public enum ModuleType: Codable, Hashable, Identifiable {
    public var id: Int { hashValue }

    case contract
    case implementation
    case mock
}
