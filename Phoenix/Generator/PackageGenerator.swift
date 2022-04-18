import Foundation
import Package

struct PackageGenerator {
    private let fileManager = FileManager.default
    private let packageStringProvider = PackageStringProvider()

    func generate(package: Package, at url: URL) throws {
        try createPackageFolderIfNecessary(at: url)

        try package.targets.forEach { target in
            if target.isTest {
                try createTestsFolderIfNecessary(at: url, name: target.name)
            } else {
                try createSourcesFolderIfNecessary(at: url, name: target.name)
            }
        }
        try createPackageFile(for: package, at: url)
        try createReadMeFileIfNecessary(at: url, withName: package.name)
    }

    private func createPackageFolderIfNecessary(at url: URL) throws {
        let path = url.path
        if !fileManager.fileExists(atPath: path) {
            try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true)
        }
    }

    private func createSourcesFolderIfNecessary(at url: URL, name: String) throws {
        let path = url.appendingPathComponent("Sources").appendingPathComponent(name, isDirectory: true).path
        if !fileManager.fileExists(atPath: path) {
            try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true)
        }

        try createSourceFile(name: name, atPath: path)
    }

    private func createTestsFolderIfNecessary(at url: URL, name: String) throws {
        let path = url.appendingPathComponent("Tests").appendingPathComponent(name, isDirectory: true).path
        if !fileManager.fileExists(atPath: path) {
            try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true)
        }

        try createTestFile(name: name, atPath: path)
    }

    private func isDirectoryEmpty(atPath path: String) -> Bool {
        do {
            let contents = try fileManager.contentsOfDirectory(atPath: path)
            return contents.isEmpty
        } catch {
            return false
        }
    }

    private func createSourceFile(name: String, atPath path: String) throws {
        guard isDirectoryEmpty(atPath: path) else { return }

        let content: String = """
struct \(name) {
    var text: String = "Hello, World!"
}

"""

        fileManager.createFile(atPath: path.appending("/\(name).swift"),
                               contents: content.data(using: .utf8),
                               attributes: nil)
    }

    private func createTestFile(name: String, atPath path: String) throws {
        guard isDirectoryEmpty(atPath: path) else { return }

        var className = name
        if className.hasSuffix("Tests") {
            className = String(className.dropLast(5))
        }

        let content: String = """
import XCTest
@testable import \(className)

final class \(name): XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(\(className)().text, "Hello, World!")
    }
}

"""
        fileManager.createFile(atPath: path.appending("/\(name).swift"),
                               contents: content.data(using: .utf8),
                               attributes: nil)
    }

    func createPackageFile(for package: Package, at url: URL) throws {
        let content = packageStringProvider.string(for: package)

        let path = url.path.appending("/Package.swift")
        try? fileManager.removeItem(atPath: path)
        fileManager.createFile(atPath: path,
                               contents: content.data(using: .utf8),
                               attributes: nil)
    }

    func createReadMeFileIfNecessary(at url: URL, withName name: String) throws {
        let path = url.path.appending("/README.md")
        guard !fileManager.fileExists(atPath: path) else { return }

        let content: String = """
# \(name)

A description of this package.
"""
        fileManager.createFile(atPath: path,
                               contents: content.data(using: .utf8),
                               attributes: nil)
    }
}
