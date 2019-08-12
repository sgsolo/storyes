import Foundation

public protocol FullScreenModuleInput: class {
	func setSelectedStory(index: Int)
}

public protocol FullScreenModuleOutput: class {
	func fullScreenDidTapOnCloseButton(storyIndex: Int)
	func fullScreenStoriesDidEnd(storyIndex: Int)
}

public final class FullScreenAssembly {
	public static func setup(_ viewController: FullScreenViewController, storiesService: StoriesServiceInput, delegate: FullScreenModuleOutput) -> FullScreenModuleInput {
		let presenter = FullScreenPresenter()
		presenter.storiesService = storiesService
		let adapter = FullScreenCollectionViewAdapter()
		adapter.output = viewController
		
		viewController.presenter = presenter
		viewController.collectionViewAdapter = adapter
		presenter.view = viewController
		presenter.output = delegate
		return presenter
	}
}
