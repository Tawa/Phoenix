#!/usr/bin/env swift
import Foundation

struct GitHubCreateReleaseRequestBody: Encodable {
    let tagName: String
    
    enum CodingKeys: String, CodingKey {
        case tagName = "tag_name"
    }
}

struct GitHubCreateReleaseResponse: Decodable {
    let uploadURL: URL
    
    enum CodingKeys: String, CodingKey {
        case uploadURL = "upload_url"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let uploadURLString = try container.decode(String.self, forKey: .uploadURL)
        guard let uploadURL = URL(string: uploadURLString.components(separatedBy: "{").first ?? "")
        else { throw DecodingError.dataCorrupted(.init(codingPath: [CodingKeys.uploadURL], debugDescription: "bad format")) }
        self.uploadURL = uploadURL
    }
}

struct GitHubReleaseError: Error {
    let message: String
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
        
        do {
            let createReleaseResponse = try await createRelease(from: tag, token: token)
            try await uploadBuild(uploadURL: createReleaseResponse.uploadURL, buildPath: buildPath, token: token)
        } catch {
            print("Error: \(error)")
            exit(1)
        }

        exit(0)
    }
    
    static func createRelease(from tag: String, token: String) async throws -> GitHubCreateReleaseResponse {
        let url = URL(string: "https://api.github.com/repos/Tawa/Phoenix/releases")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("2022-11-28", forHTTPHeaderField: "X-GitHub-Api-Version")
        
        let body = GitHubCreateReleaseRequestBody(tagName: tag)
        request.httpBody = try? JSONEncoder().encode(body)
        
        print("Preparing release creation: \(request)")
        let (data, _) = try await URLSession.shared.data(for: request)
        print("Response Data: \(String(data: data, encoding: .utf8) ?? "\"NOT A STRING\"")")
        let response = try JSONDecoder().decode(GitHubCreateReleaseResponse.self, from: data)
        return response
    }
    
    static func uploadBuild(uploadURL: URL, buildPath: String, token: String) async throws {
        guard let buildURL = URL(string: buildPath)
        else { throw GitHubReleaseError(message: "Error creating buidlURL \(buildPath)") }
        
        print("Will Attempt to open file at: \(buildURL.absoluteString)")
        guard let data = FileManager.default.contents(atPath: buildURL.path())
        else { throw GitHubReleaseError(message: "Could not get Phoenix.app data at \(buildURL)") }
        
        var request = URLRequest(url: uploadURL.appending(queryItems: [.init(name: "name", value: "Phoenix.app.zip")]))
        request.httpMethod = "POST"
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("2022-11-28", forHTTPHeaderField: "X-GitHub-Api-Version")
        request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")

        print("Will start uploading: \(request.url?.absoluteString ?? "")")
        
        let (uploadData, _) = try await URLSession.shared.upload(for: request, from: data)
        print("Upload Response Data: \(String(data: uploadData, encoding: .utf8) ?? "")")
    }
}

Task {
    await CreateGitHubRelease.main()
}
dispatchMain()
