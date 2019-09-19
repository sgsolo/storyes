import Foundation

struct StoryScreenModule {
	let view: StoryScreenViewController
	let input: StoryScreenModuleInput
}

protocol StoryScreenModuleInput: class {
	var storyModel: StoryModel! { get set }
	var isTransitionInProgress: Bool { get set }
	
	func invalidateTimer()
	func resumeStoryScreen()
	func pauseStoryScreen()
	func stopAnimation()
	func runStoryActivityIfNeeded()
}

protocol StoryScreenModuleOutput: class {
	func needShowPrevStory()
	func needShowNextStory()
	func closeButtonDidTap()
	
	func didShowStoryWithImage()
	func didShowStoryWithVideoOrTrack()
}

final class StoryScreenAssembly {
	public static func setup(_ viewController: StoryScreenViewController, delegate: StoryScreenModuleOutput) -> StoryScreenModuleInput {
		let presenter = StoryScreenPresenter()
		presenter.storiesService = StoriesService.shared
		presenter.cacheManager = CacheService()
		
		viewController.presenter = presenter
		presenter.view = viewController
		presenter.output = delegate
		return presenter
	}
}
