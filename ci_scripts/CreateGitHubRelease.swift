#!/usr/bin/env swift
import Foundation

struct Secrets {
    private static func secrets() -> [String: Any] {
        let fileName = "Secrets"
        let path = Bundle.main.path(forResource: fileName, ofType: "json")!
        let data = try! Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
        return try! JSONSerialization.jsonObject(with: data) as! [String: Any]
    }
    
    static var baseURL: String {
        return secrets()["BASE_URL"] as! String
    }
    
    static var stripeKey: String {
        return secrets()["STRIPE_KEY"] as! String
    }
    
    static var secretKeys: [String] {
        secrets().keys
    }
    static func secret(withKey key: String) -> String? {
        secrets()[key] as? String
    }
}

class CreateGitHubRelease {
    static func main() {
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
        print("Received Token: \(token.isEmpty ? "YES": "NO")")
        print("Secret Keys: \(Secrets.secretKeys)")
    }
}

CreateGitHubRelease.main()
