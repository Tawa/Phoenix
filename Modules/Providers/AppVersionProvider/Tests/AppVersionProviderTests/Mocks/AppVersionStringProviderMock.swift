import AppVersionProviderContract

struct AppVersionStringProviderMock: CurrentAppVersionStringProviderProtocol {
    let value: String?

    func currentAppVersionString() -> String? {
        value
    }
}

