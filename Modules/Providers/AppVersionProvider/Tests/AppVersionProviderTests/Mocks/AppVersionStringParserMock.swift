import AppVersionProviderContract

struct AppVersionStringParserMock: AppVersionStringParserProtocol {
    let value: AppVersionProtocol?

    func appVersion(from string: String) -> AppVersionProtocol? {
        value
    }
}
