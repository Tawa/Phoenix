import Foundation
import RelativeURLProviderContract

extension String {
    var pathComponents: [String] {
        components(separatedBy: "/")
            .filter { !$0.isEmpty }
    }
}

public struct RelativeURLProvider: RelativeURLProviding {
    public init() {
        
    }
    
    public func path(for url: URL, relativeURL: URL) -> String {
        let urlPath = url.path
        let modulesFolderPath = relativeURL.deletingLastPathComponent().path
        
        var urlPathComponents = urlPath.pathComponents
        var modulesFolderPathComponents = modulesFolderPath.pathComponents
        
        while !urlPathComponents.isEmpty,
              urlPathComponents.first == modulesFolderPathComponents.first {
            urlPathComponents.removeFirst()
            modulesFolderPathComponents.removeFirst()
        }
        
        urlPathComponents = Array(repeating: "..", count: urlPathComponents.count)
        
        return (urlPathComponents + modulesFolderPathComponents).joined(separator: "/")
    }
}
