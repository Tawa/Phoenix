public struct Target: Equatable {
    public let name: String
    public let dependencies: [ModuleDescription]
    public let isTest: Bool
}
