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

enum PhoenixDocumentError: Error {
    case versionNotFound
    case versionUnsupported
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
        }

        throw PhoenixDocumentError.versionUnsupported
    }
}
