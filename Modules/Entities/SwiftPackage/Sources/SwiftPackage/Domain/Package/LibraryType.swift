public enum LibraryType: String, Codable, Hashable, CaseIterable, Identifiable {
    public var id: Int { hashValue }

    case dynamic
    case `static`
    case undefined
}
