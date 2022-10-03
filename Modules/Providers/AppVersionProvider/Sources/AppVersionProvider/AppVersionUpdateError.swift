import Foundation

enum AppVersionUpdateError: Error {
    case failedToGetUpdateURL
    case failedToGetCurrentAppVersion
}
