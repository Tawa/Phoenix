import AppVersionProviderContract
import Combine
import Foundation

struct GithubAsset: Decodable {
    let url: URL
    
    enum CodingKeys: String, CodingKey {
        case url = "browser_download_url"
    }
}

struct GithubVersion: Decodable {
    let url: URL
    let tagName: String
    let body: String
    let assets: [GithubAsset]
    
    enum CodingKeys: String, CodingKey {
        case url
        case tagName = "tag_name"
        case body
        case assets
    }
}


public struct GithubVersionUpdateProvider: AppVersionUpdateProviderProtocol {
    
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
            .decode(type: [GithubVersion].self, decoder: JSONDecoder())
            .map({ $0.filter { !$0.assets.isEmpty } })
            .map({ $0.map { githubVersion in AppVersionInfo(version: githubVersion.tagName, releaseNotes: githubVersion.body) }})
            .map({ AppVersions(results: $0) })
            .eraseToAnyPublisher()
    }
}
