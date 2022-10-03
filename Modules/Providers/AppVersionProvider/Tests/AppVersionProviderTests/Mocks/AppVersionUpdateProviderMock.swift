import AppVersionProviderContract
import Combine

struct AppVersionUpdateProviderMock: AppVersionUpdateProviderProtocol {
    let result: Result<AppVersions, Error>
    
    func appVersionsPublisher() -> AnyPublisher<AppVersions, Error> {
        switch result {
        case .success(let success):
            return Just(success)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        case .failure(let failure):
            return Fail(error: failure)
                .eraseToAnyPublisher()
        }
    }
}
