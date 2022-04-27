public enum ModuleType: Codable, Hashable, Identifiable, CaseIterable {
    public var id: Int { hashValue }

    case contract
    case implementation
    case mock
}
