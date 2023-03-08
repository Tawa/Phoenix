#!/usr/bin/env swift
import Foundation

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
    }
}

CreateGitHubRelease.main()
