import Foundation

public protocol FullScreenModuleInput: class {
}

public protocol FullScreenModuleOutput: class {
	func fullScreenDidTapOnCloseButton()
	func fullScreenStoriesDidEnd()
}

public final class FullScreenAssembly {
	public static func setup(_ viewController: FullScreenViewController, delegate: FullScreenModuleOutput) -> FullScreenModuleInput {
		let presenter = FullScreenPresenter()
		let adapter = FullScreenCollectionViewAdapter()
		adapter.output = viewController
		
		viewController.presenter = presenter
		viewController.collectionViewAdapter = adapter
		presenter.view = viewController
		presenter.output = delegate
		return presenter
	}
}
