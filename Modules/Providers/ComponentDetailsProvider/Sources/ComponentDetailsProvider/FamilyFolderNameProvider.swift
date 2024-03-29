import ComponentDetailsProviderContract
import PhoenixDocument

public struct FamilyFolderNameProvider: FamilyFolderNameProviderProtocol {
    public init() {

    }

    public func folderName(forFamily familyName: String) -> String {
        if familyName.hasSuffix("y") {
            return familyName.dropLast() + "ies"
        }
        if familyName.hasSuffix("us") {
            return familyName.dropLast(2) + "i"
        }
        if familyName.hasSuffix("s") || familyName.hasSuffix("sh") || familyName.hasSuffix("ch") || familyName.hasSuffix("x") {
            return familyName + "es"
        }

        return familyName + "s"
    }
}

