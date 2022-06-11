import AppVersionProviderContract

extension Array {
    subscript(safe index: Int) -> Element? {
        guard index < count else { return nil }
        return self[index]
    }
}

public struct CurrentAppVersionProvider: CurrentAppVersionProviderProtocol {
    let appVersionStringProvider: CurrentAppVersionStringProviderProtocol
    let appVersionStringParser: AppVersionStringParserProtocol
    
    public init(appVersionStringProvider: CurrentAppVersionStringProviderProtocol,
                appVersionStringParser: AppVersionStringParserProtocol) {
        self.appVersionStringProvider = appVersionStringProvider
        self.appVersionStringParser = appVersionStringParser
    }
    
    public func currentAppVersion() -> AppVersionProtocol? {
        guard let string = appVersionStringProvider.currentAppVersionString()
        else { return nil }
        
        return appVersionStringParser.appVersion(from: string)
    }
}
