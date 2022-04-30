public enum ModuleType: String, Codable, Hashable, Identifiable, CaseIterable, Comparable {
    public var id: Int { hashValue }

    case contract
    case implementation
    case mock

    public static func <(lhs: ModuleType, rhs: ModuleType) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
