import PhoenixDocument
import DocumentCoderContract
import Foundation
import AppVersionProviderContract

enum PhoenixDocumentConstants {
    static let appVersionFileName: String = "appversion"
    static let jsonFileExtension: String = ".json"
    static let configurationFileName: String = "config" + jsonFileExtension
    static let familyFileName: String = "family" + jsonFileExtension
}

enum PhoenixDocumentError: LocalizedError {
    case versionNotFound
    case versionUnsupported
    
    var errorDescription: String? {
        switch self {
        case .versionNotFound:
            return "File Version Not Found"
        case .versionUnsupported:
            return "File Version Unsupposed, please update Phoenix to read this file."
        }
    }
}

public struct PhoenixDocumentFileWrappersDecoder: PhoenixDocumentFileWrappersDecoderProtocol {
    private let appVersionStringParser: AppVersionStringParserProtocol

    public init(appVersionStringParser: AppVersionStringParserProtocol) {
        self.appVersionStringParser = appVersionStringParser
    }

    public func phoenixDocument(from fileWrapper: [String: FileWrapper]) throws -> PhoenixDocument {
        guard let configurationFileWrapper = fileWrapper.values.first(where: { $0.preferredFilename == PhoenixDocumentConstants.appVersionFileName }),
              let appVersionUTF8Data = configurationFileWrapper.regularFileContents,
              let appVersionString = String(data: appVersionUTF8Data, encoding: .utf8),
              let appVersion = appVersionStringParser.appVersion(from: appVersionString)
        else { throw PhoenixDocumentError.versionNotFound }

        if appVersion.stringValue.hasPrefix("1.") {
            return try PhoenixDocumentFileWrappersDecoder_1_0_0().phoenixDocument(from: fileWrapper)
        } else if appVersion.stringValue.hasPrefix("2.") {
            return try PhoenixDocumentFileWrappersDecoder_2_0_0().phoenixDocument(from: fileWrapper)
        }

        throw PhoenixDocumentError.versionUnsupported
    }
}
