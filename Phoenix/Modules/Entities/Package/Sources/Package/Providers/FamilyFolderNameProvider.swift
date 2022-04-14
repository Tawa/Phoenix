protocol FamilyFolderNameProviding {
    func folderName(forFamily familyName: String) -> String
}

struct FamilyFolderNameProvider: FamilyFolderNameProviding {
    func folderName(forFamily familyName: String) -> String {
        if familyName.hasSuffix("y") {
            return familyName.dropLast() + "ies"
        }
        return familyName + "s"
    }
}
