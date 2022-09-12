public protocol AppVersionProtocol {
    var major: Int { get }
    var minor: Int { get }
    var hotfix: Int { get }
}

public extension AppVersionProtocol {
    var stringValue: String {
        [major, minor, hotfix].map(String.init).joined(separator: ".")
    }
    
    func isOlderThan(version: AppVersionProtocol) -> Bool {
        major < version.major ||
        (major == version.major && minor < version.minor) ||
        (major == version.major && minor == version.minor && hotfix < version.hotfix)
    }
}
