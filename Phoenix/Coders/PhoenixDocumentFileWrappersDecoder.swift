import Package
import Foundation
import AppVersionProviderContract
import Resolver

protocol PhoenixDocumentFileWrappersDecoderProtocol {
    func phoenixDocument(from fileWrapper: [String: FileWrapper]) throws -> PhoenixDocument
}

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

struct PhoenixDocumentFileWrappersDecoder: PhoenixDocumentFileWrappersDecoderProtocol {
    @Injected private var appVersionStringParser: AppVersionStringParserProtocol

    func phoenixDocument(from fileWrapper: [String: FileWrapper]) throws -> PhoenixDocument {
        guard let configurationFileWrapper = fileWrapper.values.first(where: { $0.preferredFilename == PhoenixDocumentConstants.appVersionFileName }),
              let appVersionUTF8Data = configurationFileWrapper.regularFileContents,
              let appVersionString = String(data: appVersionUTF8Data, encoding: .utf8),
              let appVersion = appVersionStringParser.appVersion(from: appVersionString)
        else { throw PhoenixDocumentError.versionNotFound }

        if appVersion == "1.0.0" {
            return try PhoenixDocumentFileWrappersDecoder_1_0_0().phoenixDocument(from: fileWrapper)
        }

        throw PhoenixDocumentError.versionUnsupported
    }
}
