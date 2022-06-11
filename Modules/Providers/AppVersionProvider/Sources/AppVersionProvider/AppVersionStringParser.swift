import AppVersionProviderContract

public struct AppVersionStringParser: AppVersionStringParserProtocol {
    public init() {
        
    }

    public func appVersion(from string: String) -> AppVersionProtocol? {
        let values = string.split(separator: ".").map(String.init).compactMap(Int.init)
        return AppVersion(major: values[safe: 0] ?? 0,
                          minor: values[safe: 1] ?? 0,
                          hotfix: values[safe: 2] ?? 0)
    }
}
