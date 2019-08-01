import Foundation

protocol FullScreenPresenterInput: class {
}

protocol FullScreenPresenterOutput: class {
}

class FullScreenPresenter {
	weak var view: FullScreenViewInput!
}

extension FullScreenPresenter: FullScreenViewOutput {
	
}

extension FullScreenPresenter: FullScreenModuleInput {
	
}
