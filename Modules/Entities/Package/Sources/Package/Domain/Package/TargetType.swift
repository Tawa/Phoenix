public enum TargetType: String, Codable, Identifiable {
    public var id: Int { hashValue }
    case contract
    case implementation
    case tests
    case mock
}
