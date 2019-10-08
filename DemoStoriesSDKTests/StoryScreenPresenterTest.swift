
import XCTest
@testable import StoriesSDK

import XCTest

class StoryScreenPresenterTest: XCTestCase {

	var storyScreenPresenter: StoryScreenPresenter!
	var notificationCenterMock: NotificationCenterMock!
	var pauseTimerMock: PauseTimerMock!
	var playerMock: PlayerMock!
	var gestureRecognizersExpectation: XCTestExpectation!
	var slideViewExpectation: XCTestExpectation!
	var closeButtonExpectation: XCTestExpectation!
	var updateProgressViewExpectation: XCTestExpectation!
	var updateAnimationOnSlideExpectation: XCTestExpectation!
	var updateLoadViewExpectation: XCTestExpectation!
	var layoutSlideViewIfNeededExpectation: XCTestExpectation!
	var pauseAnimationExpectation: XCTestExpectation?
	var resumeAnimationExpectation: XCTestExpectation?
	var stopAnimationExpectation: XCTestExpectation?
	var closeButtonDidTapExpectation: XCTestExpectation?
	var didTapOnButtonWithUrlExpectation: XCTestExpectation?
	
    override func setUp() {
		super.setUp()
		initStoryPresenter()
	}
	
	override func tearDown() {
		updateProgressViewExpectation = nil
		updateAnimationOnSlideExpectation = nil
		pauseAnimationExpectation = nil
		resumeAnimationExpectation = nil
		stopAnimationExpectation = nil
		super.tearDown()
	}
	
	private func initStoryPresenter() {
		pauseTimerMock = PauseTimerMock()
		notificationCenterMock = NotificationCenterMock()
		let storyModel = self.storyModelMock()
		storyScreenPresenter = StoryScreenPresenter(view: self,
													storiesService: self,
													cacheManager: self,
													storyModel: storyModel,
													output: self,
													slideSwitchTimer: pauseTimerMock,
													notificationCenter: notificationCenterMock)
	}
	
	private func initStoryPresenterWithPlayer() {
		pauseTimerMock = PauseTimerMock()
		notificationCenterMock = NotificationCenterMock()
		playerMock = PlayerMock(url: URL(string: yandexUrlString)!)
		let storyModel = self.storyModelMock()
		storyScreenPresenter = StoryScreenPresenter(view: self,
													storiesService: self,
													cacheManager: self,
													storyModel: storyModel,
													output: self,
													slideSwitchTimer: pauseTimerMock,
													player: playerMock,
													notificationCenter: notificationCenterMock)
	}
	
	private func storyModelMock() -> StoryModel {
		return StoryModel(currentIndex: 0,
						  storyId: "",
						  data: StoryData(service: "",
										  category: "",
										  status: true,
										  header: "",
										  image: "",
										  dataSlides: [SlideModel(slideDuration: 6,
																  player: nil,
																  track: nil,
																  video: Video(storageDir: yandexUrlString),
																  image: nil,
																  frontImage: nil,
																  buttonURL: nil,
																  contentStyle: false,
																  description: nil,
																  title3: nil,
																  title2: nil,
																  title: "",
																  buttonText: nil,
																  buttonStyle: nil,
																  animationType: nil)]))
	}

	func testViewDidLoad() {
		gestureRecognizersExpectation = expectation(description: "gesture recognizers must be added")
		slideViewExpectation = expectation(description: "slide view must be added")
		closeButtonExpectation = expectation(description: "close button must be added")
		let notifications = [UIApplication.willResignActiveNotification, UIApplication.didBecomeActiveNotification]
		notificationCenterMock.didCall_addObserver = { _, _, notification, _ in
			XCTAssertTrue(notifications.contains(notification!))
		}
		
		storyScreenPresenter.viewDidLoad()
		
		wait(for: [gestureRecognizersExpectation, slideViewExpectation, closeButtonExpectation], timeout: waitTimeout, enforceOrder: true)
	}
	
	func testViewWillAppear() {
		updateProgressViewExpectation = expectation(description: "должен быть вызван метод updateProgressView")
		updateProgressViewExpectation.expectedFulfillmentCount = 2
		let pauseExpectation = expectation(description: "должен быть вызван метод Pause таймера")
		pauseTimerMock.didCall_Pause = {
			pauseExpectation.fulfill()
		}
		
		storyScreenPresenter.viewWillAppear(true)
		
		wait(for: [updateProgressViewExpectation, pauseExpectation], timeout: waitTimeout)
	}
	
	func testViewDidLayoutSubviews() {
		updateLoadViewExpectation = expectation(description: "должен быть вызван метод обновления LoadView")
		layoutSlideViewIfNeededExpectation = expectation(description: "должен быть вызван метод обновления SlideView")
		
		storyScreenPresenter.viewDidLayoutSubviews()
		
		wait(for: [updateLoadViewExpectation, layoutSlideViewIfNeededExpectation], timeout: waitTimeout)
	}
	
	func testTouchesBegan() {
		initStoryPresenterWithPlayer()
		pauseAnimationExpectation = expectation(description: "должен быть вызван метод паузы анимации")
		let pauseTimerExpectation = expectation(description: "должен быть вызван метод паузы таймера")
		let pausePlayerExpectation = expectation(description: "должен быть вызван метод паузы плеера")
		pauseTimerMock.didCall_Pause = {
			pauseTimerExpectation.fulfill()
		}
		playerMock.didCall_Pause = {
			pausePlayerExpectation.fulfill()
		}
		
		storyScreenPresenter.touchesBegan()
		
		wait(for: [pauseAnimationExpectation!, pauseTimerExpectation, pausePlayerExpectation], timeout: waitTimeout)
		
	}
	
	func testTouchesCancelled() {
		initStoryPresenterWithPlayer()
		resumeAnimationExpectation = expectation(description: "должен быть вызван метод запуска анимации")
		let resumeTimerExpectation = expectation(description: "должен быть вызван метод запуска таймера")
		let playPlayerExpectation = expectation(description: "должен быть вызван метод запуска плеера")
		pauseTimerMock.didCall_Resume = {
			resumeTimerExpectation.fulfill()
		}
		playerMock.didCall_Play = {
			playPlayerExpectation.fulfill()
		}
		
		storyScreenPresenter.touchesCancelled()
		
		wait(for: [resumeAnimationExpectation!, resumeTimerExpectation, playPlayerExpectation], timeout: waitTimeout)
	}
	
	func testTouchesEnded() {
		initStoryPresenterWithPlayer()
		resumeAnimationExpectation = expectation(description: "должен быть вызван метод запуска анимации")
		let resumeTimerExpectation = expectation(description: "должен быть вызван метод запуска таймера")
		let playPlayerExpectation = expectation(description: "должен быть вызван метод запуска плеера")
		pauseTimerMock.didCall_Resume = {
			resumeTimerExpectation.fulfill()
		}
		playerMock.didCall_Play = {
			playPlayerExpectation.fulfill()
		}
		
		storyScreenPresenter.touchesEnded()
		
		wait(for: [resumeAnimationExpectation!, resumeTimerExpectation, playPlayerExpectation], timeout: waitTimeout)
	}
	
	func testCloseButtonDidTap() {
		stopAnimationExpectation = expectation(description: "должен быть вызван метод остановки анимации")
		closeButtonDidTapExpectation = expectation(description: "должен быть вызван метод closeButtonDidTap")
		
		storyScreenPresenter.closeButtonDidTap()
		
		wait(for: [stopAnimationExpectation!, closeButtonDidTapExpectation!], timeout: waitTimeout)
	}
	
	func testDidTapOnButton() {
		didTapOnButtonWithUrlExpectation = expectation(description: "должен быть вызван метод didTapOnButton")
		
		storyScreenPresenter.didTapOnButton(url: URL(string: yandexUrlString)!)
		
		wait(for: [didTapOnButtonWithUrlExpectation!], timeout: waitTimeout)
	}
	
//	func testTapOnLeftSide() {
//		didTapOnButtonWithUrlExpectation = expectation(description: "должен быть вызван метод didTapOnButton")
//		
//		storyScreenPresenter.tapOnLeftSide()
//		
//		wait(for: [didTapOnButtonWithUrlExpectation!], timeout: waitTimeout)
//	}
//	
//	func testTapOnRightSide() {
//		didTapOnButtonWithUrlExpectation = expectation(description: "должен быть вызван метод didTapOnButton")
//		
//		storyScreenPresenter.tapOnRightSide()
//		
//		wait(for: [didTapOnButtonWithUrlExpectation!], timeout: waitTimeout)
//	}
	
//	func tapOnLeftSide() {
//		guard !isTransitionInProgress else { return }
//		showPrevSlide()
//	}
//
//	func tapOnRightSide() {
//		guard !isTransitionInProgress else { return }
//		showNextSlide()
//	}
//
//	func closeButtonDidTap() {
//		view.stopAnimation()
//		output?.closeButtonDidTap()
//	}
//
//	func didTapOnButton(url: URL) {
//		output?.didTapOnButton(url: url)
//	}
}

extension StoryScreenPresenterTest: StoriesServiceInput {
	var stories: [StoryModel]? {
		return []
	}
	
	var currentStoryIndex: StoryIndex {
		get {
			return StoryIndex()
		}
		set(newValue) {
			
		}
	}
	
	func getStories(completion: @escaping (Result<[StoryModel], Error>) -> Void) {
		
	}
	
	func getData(_ url: URL, completion: @escaping (Result<URL, Error>) -> Void) {
		
	}
	
	func getData(_ slideModel: SlideModel, completion: @escaping (Result<SlideViewModel, Error>) -> Void) {
		
	}
	
	func prevStory() -> StoryModel? {
		return nil
	}
	
	func nextStory() -> StoryModel? {
		return nil
	}
	
	func preloadNextStory() {
		
	}
	
	func preloadPreviousStory() {
		
	}
	
	func preloadNextSlide() {
		
	}
}

extension StoryScreenPresenterTest: CacheServiceInput {
	func getViewModel(slideModel: SlideModel) -> SlideViewModel? {
		return nil
	}
	
	func getUrlWith(stringUrl: String) -> URL? {
		return nil
	}
	
	func saveToCacheIfNeeded(_ url: URL, currentLocation: URL) -> URL? {
		return nil
	}
}

extension StoryScreenPresenterTest: StoryScreenViewInput {
	func addSlideView() {
		slideViewExpectation.fulfill()
	}
	
	func addGestureRecognizers() {
		gestureRecognizersExpectation.fulfill()
	}
	
	func addCloseButton() {
		closeButtonExpectation.fulfill()
	}
	
	func updateProgressView(storyModel: StoryModel, needProgressAnimation: Bool) {
		updateProgressViewExpectation.fulfill()
	}
	
	func updateAnimationOnSlide(model: SlideViewModel, needAnimation: Bool) {
		updateAnimationOnSlideExpectation.fulfill()
	}
	
	func pauseAnimation() {
		pauseAnimationExpectation?.fulfill()
	}
	
	func resumeAnimation() {
		resumeAnimationExpectation?.fulfill()
	}
	
	func stopAnimation() {
		stopAnimationExpectation?.fulfill()
	}
	
	func showSlide(model: SlideViewModel) {
		
	}
	
	func addLoadingView() {
		
	}
	
	func removeLoadingView() {
		
	}
	
	func addNetworkErrorView() {
		
	}
	
	func removeNetworkErrorView() {
		
	}
	
	func updateLoadViewFrame() {
		updateLoadViewExpectation.fulfill()
	}
	
	func layoutSlideViewIfNeeded() {
		layoutSlideViewIfNeededExpectation.fulfill()
	}
	
	func showErrorAlert(error: Error) {
		
	}
	
	func restartAnimationForIOS10() {
		
	}
	
	func updateAnimationFractionComplete() {
		
	}
}

extension StoryScreenPresenterTest: StoryScreenModuleOutput {
	func needShowPrevStory() {
		
	}
	
	func needShowNextStory() {
		
	}
	
	func closeButtonDidTap() {
		closeButtonDidTapExpectation?.fulfill()
	}
	
	func didTapOnButton(url: URL) {
		didTapOnButtonWithUrlExpectation?.fulfill()
	}
	
	func didShowStoryWithImage() {
		
	}
	
	func didShowStoryWithVideoOrTrack() {
		
	}
}

final class NotificationCenterMock: NotificationCenter {
	var didCall_addObserver: ((Any, Selector, NSNotification.Name?, Any?) -> Void)?
	override func addObserver(_ observer: Any, selector aSelector: Selector, name aName: NSNotification.Name?, object anObject: Any?) {
		super.addObserver(observer, selector: aSelector, name: aName, object: anObject)
		didCall_addObserver?(observer, aSelector, aName, anObject)
	}
}

final class PauseTimerMock: PauseTimerInput {
	var isTimerScheduled: Bool = false
	
	func scheduledTimer(withTimeInterval interval: TimeInterval, repeats: Bool, block: @escaping (Timer) -> Void) {
		isTimerScheduled = true
	}
	
	var didCall_Invalidate: (() -> Void)?
	func invalidate() {
		isTimerScheduled = false
		didCall_Invalidate?()
	}
	var didCall_Pause: (() -> Void)?
	func pause() {
		didCall_Pause?()
	}
	
	var didCall_Resume: (() -> Void)?
	func resume() {
		didCall_Resume?()
	}
	
	
}

import AVFoundation

final class PlayerMock: PlayerInput {
	var avPlayer: AVPlayer
	
	init(url: URL) {
		avPlayer = AVPlayer(url: url)
	}
	
	var didCall_Play: (() -> Void)?
	func play() {
		didCall_Play?()
	}
	
	var didCall_Stop: (() -> Void)?
	func stop() {
		didCall_Stop?()
	}
	
	var didCall_Pause: (() -> Void)?
	func pause() {
		didCall_Pause?()
	}
}
