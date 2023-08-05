public struct Executable: Codable, Hashable, Comparable {
    public let name: String
    public let targets: [String]

    public init(name: String, targets: [String]) {
        self.name = name
        self.targets = targets
    }

    public static func <(lhs: Executable, rhs: Executable) -> Bool {
        lhs.name < rhs.name
    }
}
