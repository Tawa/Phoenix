public enum MacOSVersion: String, Codable, Hashable, CaseIterable, Identifiable {
    public var id: Int { hashValue }

    case v10_10
    case v10_11
    case v10_12
    case v10_13
    case v10_14
    case v10_15
    case v11
    case v12
}
