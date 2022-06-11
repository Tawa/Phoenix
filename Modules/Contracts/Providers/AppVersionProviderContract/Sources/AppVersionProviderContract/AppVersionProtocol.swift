public protocol AppVersionProtocol {
    var major: Int { get }
    var minor: Int { get }
    var hotfix: Int { get }
}

public func ==(lhs: AppVersionProtocol, rhs: String) -> Bool {
    return [lhs.major, lhs.minor, lhs.hotfix].map(String.init).joined(separator: ".") == rhs
}
