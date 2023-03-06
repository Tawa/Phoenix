#!/usr/bin/env swift
import Foundation
import RegexBuilder

// Phoenix.xcodeproj/xcshareddata/xcschemes/Phoenix.xcscheme

class EnableGithubReleaseTarget {
    static func main() {
        guard CommandLine.argc == 2 else { exit(1) }

        let arguments = CommandLine.arguments
        
        guard let currentDirectoryURL = URL(string: FileManager.default.currentDirectoryPath)
        else {
            print("Error getting current working directory")
            exit(1)
        }
        
        let xcschemeFileURL = properURL(path: arguments[1], relativeURL: currentDirectoryURL)

        do {
            try update(xcschemeFile: xcschemeFileURL)
        } catch {
            print("Error: \(error)")
            exit(1)
        }
        
        print("Great Success: \(xcschemeFileURL)")
    }
    
    static func properURL(path: String, relativeURL: URL) -> URL {
        var relativeURL = relativeURL
        var path = path
        while path.hasPrefix("../") {
            path.removeFirst(3)
            relativeURL = relativeURL.deletingLastPathComponent()
        }
        let possibleURL = URL(filePath: relativeURL.appending(path: path).path(),
                              directoryHint: .isDirectory)
        if FileManager.default.isDeletableFile(atPath: possibleURL.path) {
            return possibleURL
        }
        return URL(filePath: path, directoryHint: .isDirectory)
    }
    
    static func update(xcschemeFile fileURL: URL) throws {
        guard let data = FileManager.default.contents(atPath: fileURL.path)
        else { throw NSError(domain: "Missing File Data", code: -1, userInfo: nil) }
        
        guard var string = String(data: data, encoding: .utf8)
        else { throw NSError(domain: "Could not load String", code: -1, userInfo: nil) }

        let regex = Regex {
            Capture {"<EnvironmentVariable"}
            OneOrMore(.whitespace)
            Capture { "key = \"release_destination\"" }
            OneOrMore(.whitespace)
            Capture { "value = \"github\"" }
            OneOrMore(.whitespace)
            Capture { "isEnabled = \"NO\"" }
        }

        if let match = string.firstMatch(of: regex) {
            print("Found Match")
            string.replaceSubrange(match.output.4.startIndex..<match.output.4.endIndex, with: "isEnabled = \"YES\"")
            print("Replaced Substring")
        }

        guard let newData = string.data(using: .utf8)
        else { throw NSError(domain: "Could not create data", code: -1, userInfo: nil) }

        let success = FileManager.default.createFile(atPath: fileURL.path, contents: newData, attributes: nil)
        
        guard success
        else { throw NSError(domain: "Could not write file", code: -1, userInfo: nil) }
    }
}

EnableGithubReleaseTarget.main()
