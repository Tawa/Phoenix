import Foundation

public protocol RelativeURLProviderProtocol {
    func path(for url: URL, relativeURL: URL) -> String
}
