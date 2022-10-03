import AppVersionProviderContract

struct CurrentAppVersionProviderMock: CurrentAppVersionProviderProtocol {
    let value: AppVersionProtocol?
    
    func currentAppVersion() -> AppVersionProtocol? {
        value
    }
}
