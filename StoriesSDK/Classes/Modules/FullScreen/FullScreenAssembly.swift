import Foundation

public protocol FullScreenModuleInput: class {
	func setSelectedStory(index: Int)
}

public protocol FullScreenModuleOutput: class {
	func fullScreenDidTapOnCloseButton(storyIndex: Int)
	func fullScreenStoriesDidEnd(storyIndex: Int)
	
	func didShowStoryWithImage()
	func didShowStoryWithVideoOrTrack()
	
	func didTapOnButton(url: URL, storyIndex: Int)
}

final class FullScreenAssembly {
	static func setup(_ viewController: FullScreenViewController, storiesService: StoriesServiceInput, delegate: FullScreenModuleOutput) -> FullScreenModuleInput {
		let presenter = FullScreenPresenter(view: viewController, storiesService: storiesService, output: delegate)
		viewController.presenter = presenter
		return presenter
	}
}
