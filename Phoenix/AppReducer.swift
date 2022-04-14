import ComposableArchitecture
import Package

let appReducer = Reducer<FileStructure, AppAction, AppEnvironment> { state, action, environment in
    switch action {
    case .addComponent:
        state.components.append(
            Component(
                name: Name(given: "Wordpress", family: "Repository"),
                types: [:],
                platforms: []))
    }

    return .none
}
