import Foundation

public protocol RelativeURLProviding {
    func path(for url: URL, relativeURL: URL) -> String
}
