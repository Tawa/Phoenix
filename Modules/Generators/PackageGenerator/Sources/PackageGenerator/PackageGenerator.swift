import PackageGeneratorContract
import PackageStringProviderContract
import Foundation
import SwiftPackage

extension SwiftPackage {
    var isMacroPackage: Bool {
        targets.contains(where: { $0.type == .macro })
    }
}

public struct PackageGenerator: PackageGeneratorProtocol {
    let fileManager: FileManager
    let packageStringProvider: PackageStringProviderProtocol
    
    public init(fileManager: FileManager,
                packageStringProvider: PackageStringProviderProtocol) {
        self.fileManager = fileManager
        self.packageStringProvider = packageStringProvider
    }
    
    public func generate(package: SwiftPackage, at url: URL) throws {
        try createPackageFolderIfNecessary(at: url)
        
        try package.targets.forEach { target in
            switch target.type {
            case .executableTarget:
                try createExecutableSourcesFolderIfNecessary(at: url, name: target.name, importName: package.name)
                try createResourceFoldersIfNecessary(inFolder: "Sources", at: url, for: target)
            case .target:
                try createSourcesFolderIfNecessary(at: url, name: target.name)
                try createResourceFoldersIfNecessary(inFolder: "Sources", at: url, for: target)
            case .testTarget:
                try createTestsFolderIfNecessary(at: url, name: target.name, isMacroPackage: package.isMacroPackage)
                try createResourceFoldersIfNecessary(inFolder: "Tests", at: url, for: target)
            case .macro:
                try createMacroSourcesFolderIfNecessary(at: url, name: target.name)
                try createResourceFoldersIfNecessary(inFolder: "Sources", at: url, for: target)
            case .meta:
                try recreateMetaSourcesFolder(at: url, name: target.name)
                try symlinkMetaPackageSources(inFolder: "Sources", from: url, for: target)
            }
        }
        //here we make sure all the child dependencies are added?
        try createPackageFile(for: package, at: url)
        try createReadMeFileIfNecessary(at: url, withName: package.name)
    }
    
    private func createResourceFoldersIfNecessary(inFolder folder: String, at url: URL, for target: Target) throws {
        for resource in target.resources {
            // Resources folder needs to be created inside the right folder for the given Target
            let newURL = url
                .appendingPathComponent(folder)
                .appendingPathComponent(target.name)
            _ = try createFolderIfNecessary(folder: resource.folderName, at: newURL, withName: "")
        }
    }
    
    private func createPackageFolderIfNecessary(at url: URL) throws {
        let path = url.path
        if !fileManager.fileExists(atPath: path) {
            try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true)
        }
    }
    
    private func createExecutableSourcesFolderIfNecessary(at url: URL, name: String, importName: String) throws {
        let path = try createFolderIfNecessary(folder: "Sources", at: url, withName: name)
        try createExecutableSourceFile(name: "main", atPath: path, importName: importName)
    }
    
    public func createMacroSourcesFolderIfNecessary(at url: URL, name: String) throws {
        let path = try createFolderIfNecessary(folder: "Sources", at: url, withName: name)
        try createMacroSourceFile(name: name, atPath: path)
    }
    
    private func createSourcesFolderIfNecessary(at url: URL, name: String) throws {
        let path = try createFolderIfNecessary(folder: "Sources", at: url, withName: name)
        try createSourceFile(name: name, atPath: path)
    }
    
    private func recreateMetaSourcesFolder(at url: URL, name: String) throws {
        _ = try recreateFolder(folder: "Sources", at: url, withName: name)
    }
    
    private func symlinkMetaPackageSources(inFolder: String, from url: URL, for target: Target) throws {
        let atPath = url
            .appendingPathComponent(inFolder)
            .appendingPathComponent(target.name)
        let shell = Shell(verbose: true)
        
        for dependency in target.dependencies {
            if case let .module(path, name) = dependency {
                // Get the absolute URL from relative
                let absluteDestURL = URL(string: path, relativeTo: url)!.absoluteURL
                    .appendingPathComponent("Sources")
                    .appendingPathComponent(name)
                print("atPath: \(atPath)")
                print("absluteDestURL: \(absluteDestURL)")
                print("absluteDestURL.absoluteString: \(absluteDestURL.absoluteString)")
                let destPath = absluteDestURL.relativePath(from: atPath)!
                print("destPath: \(destPath)")
                try shell.execute("ln -s \(destPath) \(atPath.absoluteString)")
            }
        }
    }
    
    private func createTestsFolderIfNecessary(at url: URL, name: String, isMacroPackage: Bool) throws {
        let path = try createFolderIfNecessary(folder: "Tests", at: url, withName: name)
        
        if isMacroPackage {
            try createMacroTestFile(name: name, atPath: path)
        } else {
            try createTestFile(name: name, atPath: path)
        }
    }
    
    private func createFolderIfNecessary(folder: String, at url: URL, withName name: String) throws -> String {
        let path = url.appendingPathComponent(folder).appendingPathComponent(name, isDirectory: true).path
        if !fileManager.fileExists(atPath: path) {
            try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true)
        }
        return path
    }
    
    private func recreateFolder(folder: String, at url: URL, withName name: String) throws -> String {
        var path = url.path
        // Delete package folder
        if fileManager.fileExists(atPath: path) {
            try fileManager.removeItem(atPath: path)
        }
        // Create package folder
        try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true)
        // Create sources folder
        path = url.appendingPathComponent(folder).appendingPathComponent(name, isDirectory: true).path
        try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true)
        return path
    }
    
    private func isDirectoryEmpty(atPath path: String) -> Bool {
        do {
            let contents = try fileManager.contentsOfDirectory(atPath: path)
            return contents.isEmpty
        } catch {
            return false
        }
    }
    
    private func createExecutableSourceFile(name: String, atPath path: String, importName: String) throws {
        guard isDirectoryEmpty(atPath: path) else { return }
        
        let content: String = """
import \(importName)

let a = 17
let b = 25

let (result, code) = #stringify(a + b)

print("The value \\(result) was produced by the code \\(code)\")
"""
        
        fileManager.createFile(atPath: path.appending("/\(name).swift"),
                               contents: content.data(using: .utf8))
    }
    
    private func createMacroPackageSourceFile(name: String, atPath path: String) throws {
        let content: String = """
// The Swift Programming Language
// https://docs.swift.org/swift-book

/// A macro that produces both a value and a string containing the
/// source code that generated the value. For example,
///
///     #stringify(x + y)
///
/// produces a tuple `(x + y, "x + y")`.
@freestanding(expression)
public macro stringify<T>(_ value: T) -> (T, String) = #externalMacro(module: "\(name)Macros", type: "StringifyMacro")
"""
        
        fileManager.createFile(atPath: path.appending("/\(name).swift"),
                               contents: content.data(using: .utf8))
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
    
    private func createSourceFileSymlink(atPath path: String,
                                         withDestinationPath destPath: String) throws {
        guard isDirectoryEmpty(atPath: path) else { return }
        
        try fileManager.createSymbolicLink(atPath:  path, withDestinationPath: destPath)
    }
    
    private func createMacroSourceFile(name: String, atPath path: String) throws {
        guard isDirectoryEmpty(atPath: path) else { return }
        
        let content: String = """
import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

/// Implementation of the `stringify` macro, which takes an expression
/// of any type and produces a tuple containing the value of that expression
/// and the source code that produced the value. For example
///
///     #stringify(x + y)
///
///  will expand to
///
///     (x + y, "x + y")
public struct StringifyMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) -> ExprSyntax {
        guard let argument = node.argumentList.first?.expression else {
            fatalError("compiler bug: the macro does not have any arguments")
        }

        return "(\\(argument), \\(literal: argument.description))"
    }
}

@main
struct \(name)Plugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        StringifyMacro.self,
    ]
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
@testable import \(className)
import XCTest

final class \(name): XCTestCase {
    func testExample() throws {
    }
}

"""
        fileManager.createFile(atPath: path.appending("/\(name).swift"),
                               contents: content.data(using: .utf8),
                               attributes: nil)
    }
    
    private func createMacroTestFile(name: String, atPath path: String) throws {
        guard isDirectoryEmpty(atPath: path) else { return }
        
        var className = name
        if className.hasSuffix("Tests") {
            className = String(className.dropLast(5))
        }
        
        let content: String = """
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(\(className)Macros)
import \(className)Macros

let testMacros: [String: Macro.Type] = [
    "stringify": StringifyMacro.self,
]
#endif

final class \(className)Tests: XCTestCase {
    func testMacro() throws {
        #if canImport(\(className)Macros)
        assertMacroExpansion(
            \"""
            #stringify(a + b)
            \""",
            expandedSource: \"""
            (a + b, "a + b")
            \""",
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testMacroWithStringLiteral() throws {
        #if canImport(\(className)Macros)
        assertMacroExpansion(
            #\"""
            #stringify("Hello, \\(name)")
            \"""#,
            expandedSource: #\"""
            ("Hello, \\(name)", #""Hello, \\(name)""#)
            \"""#,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
"""
        fileManager.createFile(atPath: path.appending("/\(name).swift"),
                               contents: content.data(using: .utf8),
                               attributes: nil)
    }
    
    func createPackageFile(for package: SwiftPackage, at url: URL) throws {
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
