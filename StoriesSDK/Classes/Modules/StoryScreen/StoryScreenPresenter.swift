import Foundation

class StoryScreenPresenter: StoryScreenModuleInput {
	var isTransitionInProgress = false
	var isContentDownloaded = false
	
	private weak var output: StoryScreenModuleOutput?
	private weak var view: StoryScreenViewInput!
	private let storiesService: StoriesServiceInput
	private let cacheManager: CacheServiceInput
	private let notificationCenter: NotificationCenter
	private let slideSwitchTimer: PauseTimerInput
	private var storyModel: StoryModel
	
	private var player: PlayerInput?
	private var isViewDidAppear = false
	
	init(view: StoryScreenViewInput,
		 storiesService: StoriesServiceInput,
		 cacheManager: CacheServiceInput,
		 storyModel: StoryModel,
		 output: StoryScreenModuleOutput?,
		 slideSwitchTimer: PauseTimerInput = PauseTimer(),
		 player: PlayerInput? = nil,
		 notificationCenter: NotificationCenter = NotificationCenter.default) {
		self.view = view
		self.output = output
		self.storiesService = storiesService
		self.cacheManager = cacheManager
		self.storyModel = storyModel
		self.notificationCenter = notificationCenter
		self.slideSwitchTimer = slideSwitchTimer
		self.player = player
	}
	
	deinit {
		notificationCenter.removeObserver(self)
	}
}

extension StoryScreenPresenter: StoryScreenViewOutput {
	func viewDidLoad() {
		view.addGestureRecognizers()
		view.addSlideView()
		view.addCloseButton()
		addObserver()
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
		output?.closeButtonDidTap()
	}
	
	func didTapOnButton(url: URL) {
		output?.didTapOnButton(url: url)
	}
	
	func networkErrorViewDidTapRetryButton() {
		showSlide()
	}
}

extension StoryScreenPresenter {
	private func showSlide() {
		guard storyModel.data.dataSlides.count > storyModel.currentIndex else { return }
		let slideModel = self.storyModel.data.dataSlides[self.storyModel.currentIndex]
		
		storiesService.preloadNextSlide()
		
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
			self.storiesService.getData(slideModel, completion: { [weak self, index = storyModel.currentIndex] result in
				switch result {
				case .success(let viewModel):
					guard let self = self, index == self.storyModel.currentIndex else { return }
					self.showSlide(viewModel: viewModel, slideModel: slideModel)
				case .failure(let error):
					DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
						self?.view.addNetworkErrorView()
					}
					print(error)
				}
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
		self.updateAnimationOnSlide(needAnimation: true)
		self.playPlayer()
		guard let viewModel = cacheManager.getViewModel(slideModel: slideModel) else { return }
		self.notifyOutputIfNeeded(viewModel: viewModel)
	}
	
	private func notifyOutputIfNeeded(viewModel: SlideViewModel) {
		switch viewModel.type {
		case .image:
			output?.didShowStoryWithImage()
		case .video, .track:
			output?.didShowStoryWithVideoOrTrack()
		}
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
	
	private func addObserver() {
		notificationCenter.addObserver(self,
									   selector: #selector(applicationDidEnterBackgroundHandler),
									   name: NSNotification.Name.UIApplicationWillResignActive,
									   object: nil)
		notificationCenter.addObserver(self,
									   selector: #selector(applicationWillEnterForegroundHandler),
									   name: NSNotification.Name.UIApplicationDidBecomeActive,
									   object: nil)
	}
	
	@objc private func applicationDidEnterBackgroundHandler() {
		updateAnimationFractionComplete()
		pauseStoryScreen()
	}
	
	@objc private func applicationWillEnterForegroundHandler() {
		if #available(iOS 11.0, *) {
		} else {
			restartAnimationForIOS10()
		}
		resumeStoryScreen()
	}
	
	private func updateAnimationFractionComplete() {
		view.updateAnimationFractionComplete()
	}
	
	private func restartAnimationForIOS10() {
		view.restartAnimationForIOS10()
	}
}
