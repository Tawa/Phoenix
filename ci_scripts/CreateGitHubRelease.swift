#!/usr/bin/env swift
import Foundation

struct GitHubCreateReleaseRequestBody: Encodable {
    let tagName: String
    
    enum CodingKeys: String, CodingKey {
        case tagName = "tag_name"
    }
}

struct CreateGitHubRelease {
    static func main() async {
        print("Create GitHub Release Script")
        guard CommandLine.argc == 4
        else {
            print("Wrong number of parameters")
            exit(1)
        }
        
        let arguments = CommandLine.arguments
        
        let tag = arguments[1]
        let buildPath = arguments[2]
        let token = arguments[3]
        
        print("Received Tag: \(tag)")
        print("Received build path: \(buildPath)")
        print("Received Token: \(token.isEmpty ? "NO": "YES")")
        
        await createRelease(from: tag, token: token)
        
        exit(0)
    }
    
    static func createRelease(from tag: String, token: String) async {
        let url = URL(string: "https://api.github.com/repos/Tawa/Phoenix/releases")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("2022-11-28", forHTTPHeaderField: "X-GitHub-Api-Version")
        
        let body = GitHubCreateReleaseRequestBody(tagName: tag)
        request.httpBody = try? JSONEncoder().encode(body)
        
        do {
            print("Preparing release creation: \(request)")
            let (data, _) = try await URLSession.shared.data(for: request)
            print("Response Data: \(String(data: data, encoding: .utf8) ?? "\"NOT A STRING\"")")
        } catch {
            print("Error: \(error)")
            exit(1)
        }
    }
}

Task {
    await CreateGitHubRelease.main()
}
dispatchMain()
