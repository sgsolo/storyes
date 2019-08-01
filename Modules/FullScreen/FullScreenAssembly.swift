import Foundation

public protocol FullScreenModuleInput: class {
}

protocol FullScreenModuleOutput: class {
}

public final class FullScreenAssembly {
	public static func setup(_ viewController: FullScreenViewController/*, delegate: FullScreenModuleOutput*/) -> FullScreenModuleInput {
		let presenter = FullScreenPresenter()
		let adapter = FullScreenCollectionViewAdapter()
		
		viewController.presenter = presenter
		viewController.collectionViewAdapter = adapter
		presenter.view = viewController
//		presenter.output = delegate
		return presenter
	}
}
