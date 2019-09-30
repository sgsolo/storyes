import CoreGraphics
import Foundation

class FullScreenPresenter {
	weak var view: FullScreenViewInput!
	weak var output: FullScreenModuleOutput?
	let storiesService: StoriesServiceInput
	
	var currentStory = Story()
	private var slideSwitchTimer = PauseTimer()
	
	init(storiesService: StoriesServiceInput) {
		self.storiesService = storiesService
	}
}

extension FullScreenPresenter: FullScreenViewOutput {
	func viewDidLoad() {
		view.addBackgroundView()
		view.addSwipeGestureRecognizer()
		view.addHideGestureRecognizer()
	}

	func closeButtonDidTap() {
		output?.fullScreenDidTapOnCloseButton(storyIndex: currentStory.storyIndex)
	}
	
	func needShowPrevStory() {
		showPrevStory()
	}
	
	private func showPrevStory() {
		guard let prevStory = prevStory() else {
			output?.fullScreenStoriesDidEnd(storyIndex: currentStory.storyIndex)
			return
		}
		currentStory.storyIndex -= 1
		view.showStory(storyModel: prevStory, direction: .leftToRight)
		preloadPrevious()
	}
	
	func needShowNextStory() {
		showNextStory()
	}
	
	private func showNextStory() {
		guard let nextStoty = nextStory() else {
			output?.fullScreenStoriesDidEnd(storyIndex: currentStory.storyIndex)
			return
		}
		currentStory.storyIndex += 1
		view.showStory(storyModel: nextStoty, direction: .rightToLeft)
		preloadNext()
	}
	
	private func prevStory() -> StoryModel? {
		if let stories = storiesService.stories,
			stories.count > currentStory.storyIndex,
			currentStory.storyIndex - 1 >= 0 {
			return stories[currentStory.storyIndex - 1]
		}
		return nil
	}
	
	private func nextStory() -> StoryModel? {
		if let stories = storiesService.stories,
			stories.count > currentStory.storyIndex + 1 {
			return stories[currentStory.storyIndex + 1]
		}
		return nil
	}
	
	func panGestureRecognizerBegan(direction: Direction) {
		switch direction {
		case .leftToRight:
			guard let prevStory = prevStory() else {
				output?.fullScreenStoriesDidEnd(storyIndex: currentStory.storyIndex)
				return
			}
			view.startInteractiveTransition(storyModel: prevStory)
		case .rightToLeft:
			guard let nextStoty = nextStory() else {
				output?.fullScreenStoriesDidEnd(storyIndex: currentStory.storyIndex)
				return
			}
			view.startInteractiveTransition(storyModel: nextStoty)
		}
	}
	
	func interactiveTransitionDidEnd(direction: Direction) {
		switch direction {
		case .leftToRight:
			currentStory.storyIndex -= 1
			preloadPrevious()
		case .rightToLeft:
			currentStory.storyIndex += 1
			preloadNext()
		}
	}
	
	private func preloadNext() {
		let nextStoryIndex = currentStory.storyIndex + 1
		if let stories = storiesService.stories, stories.count > nextStoryIndex, stories[nextStoryIndex].data.dataSlides.count > 0 {
			storiesService.addDownloadQueue(slideModel: stories[nextStoryIndex].data.dataSlides[0])
		}
	}
	
	private func preloadPrevious() {
		let prevStoryIndex = currentStory.storyIndex - 1
		if let stories = storiesService.stories,
			stories.count > prevStoryIndex,
			prevStoryIndex >= 0,
			stories[prevStoryIndex].data.dataSlides.count > 0 {
			storiesService.addDownloadQueue(slideModel: stories[prevStoryIndex].data.dataSlides[0])
		}
	}
	
	func didShowStoryWithImage() {
		output?.didShowStoryWithImage()
	}
	
	func didShowStoryWithVideoOrTrack() {
		output?.didShowStoryWithVideoOrTrack()
	}
	
	func didTapOnButton(url: URL) {
		output?.didTapOnButton(url: url, storyIndex: currentStory.storyIndex)
	}
}

extension FullScreenPresenter: FullScreenModuleInput {
	func setSelectedStory(index: Int) {
		currentStory.storyIndex = index
		if let stories = storiesService.stories, stories.count > index {
			view.showInitialStory(storyModel: stories[index])
			preloadNext()
		}
	}
}
