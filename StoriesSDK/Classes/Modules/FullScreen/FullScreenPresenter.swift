import CoreGraphics
import Foundation

class FullScreenPresenter {
	private weak var view: FullScreenViewInput!
	private weak var output: FullScreenModuleOutput?
	private let storiesService: StoriesServiceInput
	private var slideSwitchTimer = PauseTimer()
	
	init(view: FullScreenViewInput, storiesService: StoriesServiceInput, output: FullScreenModuleOutput) {
		self.view = view
		self.storiesService = storiesService
		self.output = output
	}
}

extension FullScreenPresenter: FullScreenViewOutput {
	func viewDidLoad() {
		view.addBackgroundView()
		view.addSwipeGestureRecognizer()
		view.addHideGestureRecognizer()
	}

	func closeButtonDidTap() {
		output?.fullScreenDidTapOnCloseButton(storyIndex: storiesService.currentStoryIndex.storyIndex)
	}
	
	func needShowPrevStory() {
		showPrevStory()
	}
	
	private func showPrevStory() {
		guard let prevStory = storiesService.prevStory() else {
			output?.fullScreenStoriesDidEnd(storyIndex: storiesService.currentStoryIndex.storyIndex)
			return
		}
		storiesService.currentStoryIndex.storyIndex -= 1
		view.showStory(storyModel: prevStory, direction: .leftToRight)
		preloadPrevious()
	}
	
	func needShowNextStory() {
		showNextStory()
	}
	
	private func showNextStory() {
		guard let nextStory = storiesService.nextStory() else {
			output?.fullScreenStoriesDidEnd(storyIndex: storiesService.currentStoryIndex.storyIndex)
			return
		}
		storiesService.currentStoryIndex.storyIndex += 1
		view.showStory(storyModel: nextStory, direction: .rightToLeft)
		preloadNext()
	}
	
	func panGestureRecognizerBegan(direction: Direction) {
		switch direction {
		case .leftToRight:
			guard let prevStory = storiesService.prevStory() else {
				output?.fullScreenStoriesDidEnd(storyIndex: storiesService.currentStoryIndex.storyIndex)
				return
			}
			view.startInteractiveTransition(storyModel: prevStory)
		case .rightToLeft:
			guard let nextStoty = storiesService.nextStory() else {
				output?.fullScreenStoriesDidEnd(storyIndex: storiesService.currentStoryIndex.storyIndex)
				return
			}
			view.startInteractiveTransition(storyModel: nextStoty)
		}
	}
	
	func interactiveTransitionDidEnd(direction: Direction) {
		switch direction {
		case .leftToRight:
			storiesService.currentStoryIndex.storyIndex -= 1
			preloadPrevious()
		case .rightToLeft:
			storiesService.currentStoryIndex.storyIndex += 1
			preloadNext()
		}
	}
	
	private func preloadNext() {
		storiesService.preloadNextStory()
	}
	
	private func preloadPrevious() {
		storiesService.preloadPreviousStory()
	}
	
	func didShowStoryWithImage() {
		output?.didShowStoryWithImage()
	}
	
	func didShowStoryWithVideoOrTrack() {
		output?.didShowStoryWithVideoOrTrack()
	}
	
	func didTapOnButton(url: URL) {
		output?.didTapOnButton(url: url, storyIndex: storiesService.currentStoryIndex.storyIndex)
	}
}

extension FullScreenPresenter: FullScreenModuleInput {
	func setSelectedStory(index: Int) {
		storiesService.currentStoryIndex.storyIndex = index
		if let stories = storiesService.stories, stories.count > index {
			view.showInitialStory(storyModel: stories[index])
			preloadNext()
		}
	}
}
