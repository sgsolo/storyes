import CoreGraphics
import Foundation

class FullScreenPresenter {
	weak var output: FullScreenModuleOutput!
	weak var view: FullScreenViewInput!
	var storiesService: StoriesServiceInput!
	
	var currentStory = Story()
	private var slideSwitchTimer = PauseTimer()
	private var isFullScreenStoriesDidEnded = false
}

extension FullScreenPresenter: FullScreenViewOutput {
	func loadView() {
		view.addBackgroundView()
		view.addPanGestureRecognizer()
	}

	func closeButtonDidTap() {
		output.fullScreenDidTapOnCloseButton(storyIndex: currentStory.storyIndex)
	}
	
	func needShowPrevStory() {
		showPrevStory()
	}
	
	private func showPrevStory() {
		if let stories = storiesService.stories,
			stories.count > currentStory.storyIndex,
			currentStory.storyIndex - 1 >= 0 {
			currentStory.storyIndex -= 1
			view.showStory(storyModel: stories[currentStory.storyIndex], direction: .leftToRight)
			preloadPrevious()
		} else if currentStory.storyIndex == 0,
			currentStory.slideIndex == 0 {
			output.fullScreenStoriesDidEnd(storyIndex: currentStory.storyIndex)
		}
	}
	
	func needShowNextStory() {
		showNextStory()
	}
	
	private func showNextStory() {
		if let stories = storiesService.stories,
			stories.count > currentStory.storyIndex,
			stories.count == currentStory.storyIndex + 1 {
			output.fullScreenStoriesDidEnd(storyIndex: currentStory.storyIndex)
		} else if let stories = storiesService.stories,
			stories.count > currentStory.storyIndex {
			currentStory.storyIndex += 1
			view.showStory(storyModel: stories[currentStory.storyIndex], direction: .rightToLeft)
			preloadNext()
		}
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
				output.fullScreenStoriesDidEnd(storyIndex: currentStory.storyIndex)
				return
			}
			view.startInteractiveTransition(storyModel: prevStory)
		case .rightToLeft:
			guard let nextStoty = nextStory() else {
				output.fullScreenStoriesDidEnd(storyIndex: currentStory.storyIndex)
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
		if let stories = storiesService.stories, stories.count > nextStoryIndex, stories[nextStoryIndex].dataSlides.count > 0 {
			storiesService.addDownloadQueue(slideModel: stories[nextStoryIndex].dataSlides[0])
		}
	}
	
	private func preloadPrevious() {
		let prevStoryIndex = currentStory.storyIndex - 1
		if let stories = storiesService.stories,
			stories.count > prevStoryIndex,
			prevStoryIndex >= 0,
			stories[prevStoryIndex].dataSlides.count > 0 {
			storiesService.addDownloadQueue(slideModel: stories[prevStoryIndex].dataSlides[0])
		}
	}
}

extension FullScreenPresenter: FullScreenModuleInput {
	func setSelectedStory(index: Int) {
		isFullScreenStoriesDidEnded = false
		currentStory.storyIndex = index
		if let stories = storiesService.stories, stories.count > index {
			view.showInitialStory(storyModel: stories[index])
			preloadNext()
		}
	}
}
