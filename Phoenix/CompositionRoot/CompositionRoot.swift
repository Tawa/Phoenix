import Foundation
import AppVersionProviderContract
import AppVersionProvider

extension Bundle: CurrentAppVersionStringProviderProtocol {
    public func currentAppVersionString() -> String? {
        infoDictionary?["CFBundleShortVersionString"] as? String
    }
}


struct CompositionRoot {
    func register() {
        
    }
}
