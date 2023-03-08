import AppVersionProviderContract
import Combine
import Foundation

struct GitHubAsset: Decodable {
    let url: URL
    
    enum CodingKeys: String, CodingKey {
        case url = "browser_download_url"
    }
}

struct GitHubVersion: Decodable {
    let url: URL
    let tagName: String
    let body: String
    let assets: [GitHubAsset]
    
    enum CodingKeys: String, CodingKey {
        case url
        case tagName = "tag_name"
        case body
        case assets
    }
}


public struct GitHubVersionUpdateProvider: AppVersionUpdateProviderProtocol {
    
    public init() {
        
    }
    
    public func appVersionsPublisher() -> AnyPublisher<AppVersions, Error> {
        guard let url = URL(string: "https://api.github.com/repos/Tawa/Phoenix/releases")
        else {
            return Fail(error: AppVersionUpdateError.failedToGetUpdateURL)
                .eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap(\.data)
            .decode(type: [GitHubVersion].self, decoder: JSONDecoder())
            .map({ $0.filter { !$0.assets.isEmpty } })
            .map({ $0.map { gitHubVersion in AppVersionInfo(version: gitHubVersion.tagName, releaseNotes: gitHubVersion.body) }})
            .map({ AppVersions(results: $0) })
            .eraseToAnyPublisher()
    }
}
