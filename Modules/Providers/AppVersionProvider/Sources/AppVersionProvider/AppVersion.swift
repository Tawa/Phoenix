import AppVersionProviderContract

struct AppVersion: AppVersionProtocol {
    let major: Int
    let minor: Int
    let hotfix: Int
}
