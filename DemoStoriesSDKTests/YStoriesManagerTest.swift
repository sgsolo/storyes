
import XCTest
@testable import StoriesSDK

class YStoriesManagerTest: XCTestCase {

	var storiesManager: YStoriesManager!
	var storiesServiceMock: StoriesServiceMock!
	var fullScreenViewController: FullScreenViewController!
	var fullScreenDidTapOnCloseButtonException: XCTestExpectation!
	var needShowFullScreenException: XCTestExpectation?
	var fullScreenStoriesDidEndException: XCTestExpectation!
	var didShowStoryWithImageException: XCTestExpectation!
	var stopPlayerIfNeededException: XCTestExpectation!
	var didTapOnButtonWithUrlException: XCTestExpectation!
	var getStoriesException: XCTestExpectation!
	var openUrlIfPossibleException: XCTestExpectation!
	
    override func setUp() {
		super.setUp()
		storiesManager = YStoriesManager(storiesManagerOutput: self)
	}

    override func tearDown() {
		fullScreenViewController = nil
		super.tearDown()
	}

    func testConfigureForTargetAppWithColorTheme() {
		let targetApp: SupportedApp = .music
		let colorTheme = YColorTheme(false)
		
		YStoriesManager.configure(for: targetApp, with: colorTheme)
		
		XCTAssertEqual(YStoriesManager.targetApp, targetApp, "targetApp must be equal")
		XCTAssertNotNil(YStoriesManager.uiStyle, "uiStyle must be not nil")
    }
	
	func testSetColorTheme() {
		let colorTheme = YColorTheme(false)
		
		YStoriesManager.setColorTheme(colorTheme)
		
		XCTAssertNotNil(YStoriesManager.uiStyle, "uiStyle must be not nil")
	}
	
	func testFullScreenDidTapOnCloseButton() {
		storiesManager.didSelectStory(at: 0, frame: .zero)
		fullScreenDidTapOnCloseButtonException = expectation(description: "должен вызваться метод делегата fullScreenDidTapOnCloseButton")
		
		storiesManager.fullScreenDidTapOnCloseButton(storyIndex: 0)
		
		wait(for: [fullScreenDidTapOnCloseButtonException], timeout: waitTimeout)
	}
	
	func testDidSelectStoryAtIndexWithFrame() {
		needShowFullScreenException = expectation(description: "должен вызваться метод делегата needShowFullScreen")
		
		storiesManager.didSelectStory(at: 0, frame: .zero)
		
		wait(for: [needShowFullScreenException!], timeout: waitTimeout)
	}
	
	func testFullScreenStoriesDidEndAtStoryIndex() {
		storiesManager.didSelectStory(at: 0, frame: .zero)
		fullScreenStoriesDidEndException = expectation(description: "должен вызваться метод делегата fullScreenStoriesDidEndException")
		
		storiesManager.fullScreenStoriesDidEnd(storyIndex: 0)
		
		wait(for: [fullScreenStoriesDidEndException], timeout: waitTimeout)
	}
	
	func testDidShowStoryWithImage() {
		didShowStoryWithImageException = expectation(description: "должен вызваться метод делегата playPlayerIfNeeded")
		
		storiesManager.didShowStoryWithImage()
		
		wait(for: [didShowStoryWithImageException], timeout: waitTimeout)
	}
	
	func testDidShowStoryWithVideoOrTrack() {
		stopPlayerIfNeededException = expectation(description: "должен вызваться метод делегата stopPlayerIfNeeded")
		
		storiesManager.didShowStoryWithVideoOrTrack()
		
		wait(for: [stopPlayerIfNeededException], timeout: waitTimeout)
	}
	
	func testDidTapOnButtonWithUrl() {
		storiesManager.didSelectStory(at: 0, frame: .zero)
		openUrlIfPossibleException = expectation(description: "должен вызваться метод делегата openUrlIfPossible")
		
		storiesManager.didTapOnButton(url: URL(string: yandexUrlString)!, storyIndex: 0)
		
		wait(for: [openUrlIfPossibleException], timeout: waitTimeout)
	}
	
	func testSuccessLoadStories() {
		storiesServiceMock = StoriesServiceMock()
		storiesServiceMock.state = .success
		storiesManager = YStoriesManager(storiesManagerOutput: self, storiesService: storiesServiceMock)
		getStoriesException = expectation(description: "должен вызваться метод делегата getStories")
		
		storiesManager.loadStories()
		
		wait(for: [getStoriesException], timeout: waitTimeout)
	}
	
	func testFailureLoadStories() {
		storiesServiceMock = StoriesServiceMock()
		storiesServiceMock.state = .failure
		storiesManager = YStoriesManager(storiesManagerOutput: self, storiesService: storiesServiceMock)
		getStoriesException = expectation(description: "должен вызваться метод делегата storiesDidLoad")
		
		storiesManager.loadStories()
		
		wait(for: [getStoriesException], timeout: waitTimeout)
	}
	
	func testColorThemeDidChange() {
		let notificationExpectation = expectation(forNotification: YStoriesNotification.colorThemeDidChange,
												  object: nil,
												  notificationCenter: NotificationCenter.default,
												  handler: nil)
		
		storiesManager.colorThemeDidChange(YColorTheme(false))
		
		XCTAssertNotNil(YStoriesManager.uiStyle, "uiStyle must be not nil")
		wait(for: [notificationExpectation], timeout: waitTimeout)
	}
	
	func testAnimationPresentingController() {
		let animationPresentingController = storiesManager.animationController(forPresented: UIViewController(),
										   presenting: UIViewController(),
										   source: UIViewController())
		
		XCTAssertNotNil(animationPresentingController, "animationPresentingController не может быть nil")
	}
	
	func testanimationDismissedController() {
		let animationDismissedController = storiesManager.animationController(forDismissed: UIViewController())
		
		XCTAssertNotNil(animationDismissedController, "animationDismissedController не может быть nil")
	}
}

extension YStoriesManagerTest: YStoriesManagerOutput {
	func storiesDidLoad(_ isSuccess: Bool, error: Error?) {
		getStoriesException.fulfill()
	}
	
	func needShowFullScreen(_ fullScreen: FullScreenViewController) {
		fullScreenViewController = fullScreen
		needShowFullScreenException?.fulfill()
	}
	
	func fullScreenDidTapOnCloseButton(fullScreen: FullScreenViewController) {
		fullScreenDidTapOnCloseButtonException.fulfill()
	}
	
	func fullScreenStoriesDidEnd(fullScreen: FullScreenViewController) {
		fullScreenStoriesDidEndException.fulfill()
	}
	
	func openUrlIfPossible(url: URL, fullScreen: FullScreenViewController) {
		openUrlIfPossibleException.fulfill()
	}
	
	func playPlayerIfNeeded() {
		didShowStoryWithImageException.fulfill()
	}
	
	func stopPlayerIfNeeded() {
		stopPlayerIfNeededException.fulfill()
	}
}

class StoriesServiceMock: StoriesServiceInput {
	enum StoriesServiceState {
		case success
		case failure
	}
	var state: StoriesServiceState = .success
	
	var stories: [StoryModel]? {
		get { return [] }
		set {}
	}
	var currentStoryIndex: StoryIndex {
		get { return StoryIndex() }
		set {}
	}
	func getStories(completion: @escaping (Result<[StoryModel], Error>) -> Void) {
		switch state {
		case .success:
			completion(.success([]))
		case .failure:
			let error = NSError(domain: "some error", code: 0, userInfo: nil)
			completion(.failure(error))
		}
	}
	func getData(_ url: URL, completion: @escaping (Result<URL, Error>) -> Void) {}
	func getData(_ slideModel: SlideModel, completion: @escaping (Result<SlideViewModel, Error>) -> Void) {}
	func prevStory() -> StoryModel? { return nil }
	func nextStory() -> StoryModel? { return nil }
	func preloadNextStory() {}
	func preloadPreviousStory() {}
	func preloadNextSlide() {}
}
