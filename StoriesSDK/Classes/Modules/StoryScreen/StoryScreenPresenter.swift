import Foundation

class StoryScreenPresenter: StoryScreenModuleInput {
	weak var output: StoryScreenModuleOutput!
	weak var view: StoryScreenViewInput!
	var storiesService: StoriesService!
	var cacheManager: CacheServiceInput!
	
	var storyModel: StoryModel!
	var isTransitionInProgress = false
	var isContentDownloaded = false
	private var player: Player?
	private var isViewDidAppear = false
	private var slideSwitchTimer = PauseTimer()
}

extension StoryScreenPresenter: StoryScreenViewOutput {
	func viewDidLoad() {
		view.addSlideView()
		view.addGestureRecognizers()
		view.addCloseButton()
	}
	
	func viewWillAppear(_ animated: Bool) {
		view.updateProgressView(storyModel: storyModel, needProgressAnimation: false)
		updateAnimationOnSlide(needAnimation: false)
		showSlide()
		pauseTimer()
	}
	
	func viewDidLayoutSubviews() {
		view.updateLoadViewFrame()
		view.layoutSlideViewIfNeeded()
	}
	
	func viewDidAppear(_ animated: Bool) {
		isViewDidAppear = true
		if storyModel.data.dataSlides.count > storyModel.currentIndex {
			let slideModel = self.storyModel.data.dataSlides[self.storyModel.currentIndex]
			if isContentDownloaded {
				runStoryActivity(slideModel: slideModel)
			}
		}
	}
	
	func touchesBegan() {
		pauseStoryScreen()
	}
	
	func touchesCancelled() {
		resumeStoryScreen()
	}
	
	func touchesEnded() {
		resumeStoryScreen()
	}
	
	func tapOnLeftSide() {
		guard !isTransitionInProgress else { return }
		showPrevSlide()
	}
	
	func tapOnRightSide() {
		guard !isTransitionInProgress else { return }
		showNextSlide()
	}
	
	func closeButtonDidTap() {
		view.stopAnimation()
		output.closeButtonDidTap()
	}
	
	func networkErrorViewDidTapRetryButton() {
		showSlide()
	}
}

extension StoryScreenPresenter {
	private func showSlide() {
		guard storyModel.data.dataSlides.count > storyModel.currentIndex else { return }
		let slideModel = self.storyModel.data.dataSlides[self.storyModel.currentIndex]
		
		if storyModel.data.dataSlides.count > storyModel.currentIndex + 1 {
			storiesService.addDownloadQueue(slideModel: self.storyModel.data.dataSlides[self.storyModel.currentIndex + 1])
		}
		
		isContentDownloaded = false
		self.view.updateProgressView(storyModel: self.storyModel, needProgressAnimation: false)
		updateAnimationOnSlide(needAnimation: false)
		
		self.invalidateTimer()
		self.player?.stop()
		
		self.view.removeNetworkErrorView()
		if let viewModel = cacheManager.getViewModel(slideModel: slideModel) {
			self.showSlide(viewModel: viewModel, slideModel: slideModel)
		} else {
			self.view.addLoadingView()
			self.storiesService.getData(slideModel, success: { [weak self, index = storyModel.currentIndex] viewModel in
				guard let self = self, let viewModel = viewModel as? SlideViewModel, index == self.storyModel.currentIndex else { return }
				self.showSlide(viewModel: viewModel, slideModel: slideModel)
			}, failure: { [weak self] error in
				DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
					self?.view.addNetworkErrorView()
				}
				print(error)
			})
		}
	}
	
	private func showSlide(viewModel: SlideViewModel, slideModel: SlideModel) {
		var viewModel = viewModel
		self.view.removeLoadingView()
		self.isContentDownloaded = true
		self.player = nil
		let playerUrl = viewModel.videoUrl ?? viewModel.trackUrl
		if let url = playerUrl {
			self.player = Player(url: url)
			viewModel.player = self.player
		}
		self.showSlide(model: viewModel)
		if self.isViewDidAppear, !self.isTransitionInProgress {
			self.runStoryActivity(slideModel: slideModel)
		}
	}
	
	private func showSlide(model: SlideViewModel) {
		view.showSlide(model: model)
	}
	
	private func runTimerForSlide(slideModel: SlideModel) {
		self.slideSwitchTimer.scheduledTimer(withTimeInterval: TimeInterval(slideModel.duration), repeats: false, block: { [weak self] timer in
			self?.showNextSlide()
		})
	}
	
	private func updateAnimationOnSlide(needAnimation: Bool) {
		guard storyModel.data.dataSlides.count > storyModel.currentIndex else { return }
		let slideModel = self.storyModel.data.dataSlides[self.storyModel.currentIndex]
		if let viewModel = cacheManager.getViewModel(slideModel: slideModel) {
			view.updateAnimationOnSlide(model: viewModel, needAnimation: needAnimation)
		}
	}
	
	func pauseAnimation() {
		view.pauseAnimation()
	}
	
	func resumeAnimation() {
		guard !isTransitionInProgress else { return }
		view.resumeAnimation()
	}
	
	func stopAnimation() {
		view.stopAnimation()
	}
	
	func invalidateTimer() {
		self.slideSwitchTimer.invalidate()
	}
	
	func pauseTimer() {
		self.slideSwitchTimer.pause()
	}
	
	func resumeTimer() {
		guard !isTransitionInProgress else { return }
		self.slideSwitchTimer.resume()
	}
	
	func pausePlayer() {
		player?.pause()
	}
	
	func playPlayer() {
		guard !isTransitionInProgress else { return }
		player?.play()
	}
	
	func pauseStoryScreen() {
		pauseTimer()
		pauseAnimation()
		pausePlayer()
	}
	
	func resumeStoryScreen() {
		resumeTimer()
		resumeAnimation()
		playPlayer()
	}
	
	private func runStoryActivity(slideModel: SlideModel) {
		self.runTimerForSlide(slideModel: slideModel)
		self.view.updateProgressView(storyModel: self.storyModel, needProgressAnimation: true)
		updateAnimationOnSlide(needAnimation: true)
		self.playPlayer()
	}
	
	func runStoryActivityIfNeeded() {
		if storyModel.data.dataSlides.count > storyModel.currentIndex {
			let slideModel = self.storyModel.data.dataSlides[self.storyModel.currentIndex]
			if isContentDownloaded, !slideSwitchTimer.isTimerScheduled {
				runStoryActivity(slideModel: slideModel)
			}
		}
	}
	
	private func showNextSlide() {
		if storyModel.data.dataSlides.count > storyModel.currentIndex,
			storyModel.data.dataSlides.count > storyModel.currentIndex + 1 {
			storyModel.currentIndex += 1
			showSlide()
		} else if storyModel.data.dataSlides.count > storyModel.currentIndex,
			storyModel.data.dataSlides.count == storyModel.currentIndex + 1 {
			output?.needShowNextStory()
		}
	}
	
	private func showPrevSlide() {
		if storyModel.data.dataSlides.count > storyModel.currentIndex,
			storyModel.currentIndex - 1 >= 0 {
			storyModel.currentIndex -= 1
			showSlide()
		} else if storyModel.currentIndex == 0 {
			output?.needShowPrevStory()
		}
	}
}
