import Foundation

struct StoryScreenModule {
	let view: StoryScreenViewController
	let input: StoryScreenModuleInput
}

protocol StoryScreenModuleInput: class {
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
	func didTapOnButton(url: URL)
	
	func didShowStoryWithImage()
	func didShowStoryWithVideoOrTrack()
}

final class StoryScreenAssembly {
	public static func setup(_ viewController: StoryScreenViewController, storyModel: StoryModel, delegate: StoryScreenModuleOutput) -> StoryScreenModuleInput {
		let presenter = StoryScreenPresenter(view: viewController, storiesService: StoriesService.shared, cacheManager: CacheService.shared, storyModel: storyModel, output: delegate)
		viewController.presenter = presenter
		return presenter
	}
}
