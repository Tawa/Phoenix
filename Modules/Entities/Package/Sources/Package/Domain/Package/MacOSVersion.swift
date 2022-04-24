public enum MacOSVersion: Codable, Hashable, CaseIterable, Identifiable {
    public var id: Int { hashValue }

    case v12
}
