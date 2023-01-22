import AppVersionProviderContract
import Combine
import ComponentDetailsProviderContract
import DemoAppFeature
import DemoAppGeneratorContract
import Factory
import GenerateFeature
import PackageGeneratorContract
import PBXProjectSyncerContract
import PhoenixDocument
import ProjectGeneratorContract
import SwiftPackage
import SwiftUI
import UniformTypeIdentifiers

enum ComponentPopupState: Hashable, Identifiable {
    var id: Int { hashValue }
    case new
    case remote
}

enum AlertState: Hashable, Identifiable {
    var id: Int { hashValue }
    case errorString(String)
    
    var title: String {
        switch self {
        case let .errorString(value):
            return value
        }
    }
}

enum ComponentSelection {
    case component(name: Name)
    case remoteComponent(url: String)
    
    var componentName: Name? {
        guard case .component(let name) = self else { return nil }
        return name
    }
    
    var remoteComponentURL: String? {
        guard case .remoteComponent(let url) = self else { return nil }
        return url
    }
}

class ViewModel: ObservableObject {
    // MARK: - Selection
    private var selectionQueue: [ComponentSelection] = []
    private var selectionQueueIndex: Int = 0
    @Published private(set) var selection: ComponentSelection? = nil
    private func select(_ selection: ComponentSelection) {
        if selectionQueueIndex < selectionQueue.count-1 {
            selectionQueue = selectionQueue[0...selectionQueueIndex] + [selection]
        } else {
            selectionQueue.append(selection)
        }
        selectionQueueIndex = selectionQueue.count - 1
        
        undoSelectionDisabled = selectionQueue.count < 2 || selectionQueueIndex == 0
        redoSelectionDisabled = selectionQueueIndex >= selectionQueue.count - 1
        
        self.selection = selection
    }
    func select(componentName: Name) {
        select(.component(name: componentName))
    }
    func select(remoteComponentURL: String) {
        select(.remoteComponent(url: remoteComponentURL))
    }
    
    func undoSelection() {
        guard selectionQueueIndex > 0 && selectionQueueIndex < selectionQueue.count else { return }
        selectionQueueIndex -= 1
        selection = selectionQueue[selectionQueueIndex]
        undoSelectionDisabled = selectionQueue.count < 2 || selectionQueueIndex == 0
        redoSelectionDisabled = selectionQueueIndex >= selectionQueue.count - 1
    }
    
    func redoSelection() {
        guard selectionQueueIndex < selectionQueue.count - 1 else { return }
        selectionQueueIndex += 1
        selection = selectionQueue[selectionQueueIndex]
        undoSelectionDisabled = selectionQueue.count < 2 || selectionQueueIndex == 0
        redoSelectionDisabled = selectionQueueIndex >= selectionQueue.count - 1
    }
    
    @Published private(set) var undoSelectionDisabled: Bool = true
    @Published private(set) var redoSelectionDisabled: Bool = true

    // MARK: - Components List
    @Published var componentsListFilter: String? = nil

    // MARK: - Family Sheet
    @Published private(set) var selectedFamilyName: String? = nil
    func select(familyName: String?) {
        selectedFamilyName = familyName
    }
    
    // MARK: - Update Button
    private var appUpdateVersionInfoSub: AnyCancellable? = nil
    @Published var appUpdateVersionInfo: AppVersionInfo? = nil
    @Published var showingUpdatePopup: AppVersionInfo? = nil
    
    // MARK: - Sheets
    @Published var showingQuickSelectionSheet: Bool = false
    @Published var showingConfigurationPopup: Bool = false
    @Published var showingNewComponentPopup: ComponentPopupState? = nil
    @Published var showingDependencySheet: Bool = false
    @Published var showingRemoteDependencySheet: Bool = false
    @Published var alertState: AlertState? = nil
    @Published var demoAppFeatureData: DemoAppFeatureInput? = nil

    @Injected(Container.appVersionUpdateProvider)
    var appVersionUpdateProvider: AppVersionUpdateProviderProtocol
    @Injected(Container.familyFolderNameProvider)
    var familyFolderNameProvider: FamilyFolderNameProviderProtocol
        
    func onConfigurationButton() {
        showingConfigurationPopup = true
    }
    
    func onUpdateButton() {
        showingUpdatePopup = appUpdateVersionInfo
    }
    
    func onAddButton() {
        showingNewComponentPopup = .new
    }
    
    func onAddRemoteButton() {
        showingNewComponentPopup = .remote
    }

    func checkForUpdate() {
        appUpdateVersionInfoSub = appVersionUpdateProvider
            .appVersionsPublisher()
            .receive(on: DispatchQueue.main)
            .sink { _ in
            } receiveValue: { appVersionInfos in
                self.appUpdateVersionInfo = appVersionInfos.results.first
            }
    }
}
