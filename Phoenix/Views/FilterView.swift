import SwiftUI

class FilterViewData: ObservableObject {
    @Published var text: String?
}

class FilterViewInteractor {
    let clearComponentsFilterUseCase: ClearComponentsFilterUseCaseProtocol
    let updateComponentsFilterUseCase: UpdateComponentsFilterUseCaseProtocol
    let viewData: FilterViewData = .init()
    
    init(clearComponentsFilterUseCase: ClearComponentsFilterUseCaseProtocol,
         updateComponentsFilterUseCase: UpdateComponentsFilterUseCaseProtocol) {
        self.clearComponentsFilterUseCase = clearComponentsFilterUseCase
        self.updateComponentsFilterUseCase = updateComponentsFilterUseCase
    }
    
    func update(text: String) {
        updateComponentsFilterUseCase.update(value: text)
        viewData.text = text
    }
    
    func clear() {
        clearComponentsFilterUseCase.clear()
        viewData.text = nil
    }
}

struct FilterView: View {
    @ObservedObject var viewData: FilterViewData
    let interactor: FilterViewInteractor
    var onSubmit: (() -> Void)? = nil
    
    init(interactor: FilterViewInteractor,
         onSubmit: (() -> Void)? = nil) {
        self.viewData = interactor.viewData
        self.interactor = interactor
        self.onSubmit = onSubmit
    }
    
    var body: some View {
        HStack {
            TextField("Filter",
                      text: Binding(
                        get: { viewData.text ?? "" },
                        set: { interactor.update(text: $0) })
            )
            .onSubmit {
                onSubmit?()
            }
            if viewData.text?.isEmpty == false {
                Button(action: interactor.clear, label: {
                    Image(systemName: "clear.fill")
                })
                .aspectRatio(1, contentMode: .fit)
            }
        }.padding(16)
    }
}
