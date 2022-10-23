import XCTest

final class PhoenixUITests: XCTestCase {

    let screen = Screen()

    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false
    }
    
    func testAppFlow() throws {
        let wordpress = "Wordpress"
        let feature = "Feature"
        let useCases = "UseCases"
        let repository = "Repository"
        let dataStore = "DataStore"
        
        let support = "Support"
        let defaultSupport = "Supports"
        let networking = "Networking"
        
        let wordpressFeature = wordpress + feature
        let wordpressUseCases = wordpress + useCases
        let wordpressRepository = wordpress + repository
        let wordpressDataStore = wordpress + dataStore

        screen
            .launch()
            .closeAllWindowsIfNecessary()
            .createNewFile()
            .maximize()
            .configureContractImplementationAndMock()
            .addNewComponent(givenName: wordpress, familyName: feature)
            .addNewComponent(givenName: wordpress, familyName: useCases)
            .addNewComponent(givenName: wordpress, familyName: repository)
            .addNewComponent(givenName: wordpress, familyName: dataStore)
            .addNewComponent(givenName: networking, familyName: support)
            .openFamilySettings(named: defaultSupport)
            .toggleAppendName(familyName: defaultSupport)
            .set(folderName: support)
            .clickDone()
            .select(component: wordpressFeature,
                    andAddDependency: wordpressUseCases)
            .select(component: wordpressUseCases,
                    andAddDependency: wordpressRepository)
            .select(component: wordpressRepository,
                    andAddDependency: networking, wordpressDataStore)
    }
}
