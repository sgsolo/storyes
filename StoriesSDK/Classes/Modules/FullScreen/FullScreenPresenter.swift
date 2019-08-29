import CoreGraphics

//protocol FullScreenPresenterInput: class {
//}
//

class FullScreenPresenter {
	weak var output: FullScreenModuleOutput!
	weak var view: FullScreenViewInput!
	var storiesService: StoriesServiceInput!
	
	var currentStory = Story()
	private var slideSwitchTimer = PauseTimer()
	private var isFullScreenStoriesDidEnded = false
	private var isViewDidAppear = false
}

extension FullScreenPresenter: FullScreenViewOutput {
	func loadView() {
		view.configureCollectionView()
		updateData()
		scrollToStory(index: currentStory.storyIndex, animated: false)
		showSlide()
	}
	
	func viewWillAppear(_ animated: Bool) {
//		scrollToStory(index: currentStory.storyIndex, animated: false)
	}
	
	func viewDidAppear(_ animated: Bool) {
		isViewDidAppear = true
		updateData()
		scrollToStory(index: currentStory.storyIndex, animated: false)
		showSlide()
	}
	
	func viewDidDisappear(_ animated: Bool) {
		invalidateTimer()
	}
	
	//TODO: брать TimeInterval из модели слайда
	private func runTimerForSlide() {
		self.slideSwitchTimer.scheduledTimer(withTimeInterval: 6, repeats: true, block: { [weak self] timer in
			self?.showNextSlide()
		})
	}
	
	private func invalidateTimer() {
		self.slideSwitchTimer.invalidate()
	}
	
	private func pauseTimer() {
		self.slideSwitchTimer.pause()
	}
	
	private func resumeTimer() {
		self.slideSwitchTimer.resume()
	}
	
	private func pauseAnimation() {
		//!!! нельзя анимировано скрывать контроллер и при этом отключать анимацию, в этом случае пользовательский интерфейс фризится
		guard !isFullScreenStoriesDidEnded && isViewDidAppear else { return }
		self.view.pauseAnimation()
	}
	
	private func resumeAnimation() {
		guard isViewDidAppear else { return }
		self.view.resumeAnimation()
	}
	
	private func showSlide() {
		if let stories = storiesService.stories,
			stories.count > currentStory.storyIndex,
			stories[currentStory.storyIndex].count > currentStory.slideIndex {
			
			let slideModels = stories[currentStory.storyIndex]
			let slideModel = slideModels[currentStory.slideIndex]
			showSlide(model: slideModel, modelsCount: slideModels.count, modelIndex: currentStory.slideIndex)
		}
		runTimerForSlide()
	}
	
	private func updateData() {
		guard let stories = storiesService.stories else { return }
		let sectionData = CollectionSectionData(objects: stories)
		view.updateData(with: [sectionData])
	}
	
	private func scrollToStory(index: Int, animated: Bool) {
		if animated {
			view.setCollectionViewUserInteractionEnabled(false)
		}
		view.scrollToStory(index: index, animated: animated)
		if !animated {
			resumeAnimation()
			resumeTimer()
		}
	}
	
	private func showSlide(model: SlideModel, modelsCount: Int, modelIndex: Int) {
		view.showSlide(model: model, modelsCount: modelsCount, modelIndex: modelIndex)
	}
	
	func storyCellDidTapOnLeftSide() {
		assert(Thread.isMainThread)
		view.setCollectionViewScrollEnabled(true)
		showPrevSlide()
	}
	
	private func showPrevSlide() {
		if let stories = storiesService.stories,
			stories.count > currentStory.storyIndex,
			currentStory.slideIndex - 1 >= 0 {
			currentStory.slideIndex -= 1
			showSlide()
		} else if let stories = storiesService.stories,
			stories.count > currentStory.storyIndex,
			currentStory.storyIndex - 1 >= 0 {
			currentStory.storyIndex -= 1
			scrollToStory(index: currentStory.storyIndex, animated: true)
			showSlide()
		} else if currentStory.storyIndex == 0,
			currentStory.slideIndex == 0 {
			output.fullScreenStoriesDidEnd(storyIndex: currentStory.storyIndex)
		}
	}
	
	func storyCellDidTapOnRightSide() {
		assert(Thread.isMainThread)
		view.setCollectionViewScrollEnabled(true)
		showNextSlide()
	}
	
	private func showNextSlide() {
		if let stories = storiesService.stories,
			stories.count > currentStory.storyIndex,
			stories[currentStory.storyIndex].count > currentStory.slideIndex + 1 {
			currentStory.slideIndex += 1
			showSlide()
		} else if let stories = storiesService.stories,
			stories.count > currentStory.storyIndex,
			stories[currentStory.storyIndex].count == currentStory.slideIndex + 1,
			stories.count == currentStory.storyIndex + 1 {
			output.fullScreenStoriesDidEnd(storyIndex: currentStory.storyIndex)
		} else if let stories = storiesService.stories,
			stories.count > currentStory.storyIndex,
			stories[currentStory.storyIndex].count > currentStory.storyIndex + 1 {
			currentStory.storyIndex += 1
			scrollToStory(index: currentStory.storyIndex, animated: true)
			showSlide()
		}
	}
	
	func storyCellTouchesBegan() {
//		view.setCollectionViewScrollEnabled(false)
		pauseTimer()
		pauseAnimation()
	}
	
	func storyCellTouchesCancelled() {
		view.setCollectionViewScrollEnabled(true)
		resumeTimer()
		resumeAnimation()
	}
	
	func storyCellDidTouchesEnded() {
		view.setCollectionViewScrollEnabled(true)
		resumeTimer()
		resumeAnimation()
	}
	
	func didEndScrollingAnimation() {
		view.setCollectionViewUserInteractionEnabled(true)
		resumeTimer()
		resumeAnimation()
	}
	
	func collectionViewDidScroll(contentSize: CGSize, contentOffset: CGPoint) {
		pauseTimer()
		pauseAnimation()
		let margin: CGFloat = 40
		if contentSize.width + margin < contentOffset.x + UIScreen.main.bounds.width {
			self.isFullScreenStoriesDidEnded = true
			resumeAnimation()
			output.fullScreenStoriesDidEnd(storyIndex: currentStory.storyIndex)
		}
	}
	
	func collectionViewDidEndDecelerating(visibleIndexPath: IndexPath) {
		if visibleIndexPath.item != currentStory.storyIndex {
			currentStory.storyIndex = visibleIndexPath.item
			runTimerForSlide()
		}
		view.setCollectionViewScrollEnabled(true)
		resumeTimer()
		resumeAnimation()
	}
	
	func closeButtonDidTap() {
		output.fullScreenDidTapOnCloseButton(storyIndex: currentStory.storyIndex)
	}
}

extension FullScreenPresenter: FullScreenModuleInput {
	func setSelectedStory(index: Int) {
		isFullScreenStoriesDidEnded = false
		currentStory.storyIndex = index
		updateData()
		scrollToStory(index: currentStory.storyIndex, animated: false)
		showSlide()
	}
}
