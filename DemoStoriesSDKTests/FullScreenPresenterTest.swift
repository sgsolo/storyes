
let waitTimeout: TimeInterval = 0.5

import XCTest
@testable import StoriesSDK

class FullScreenPresenterTest: XCTestCase {

	var presenter: FullScreenPresenter!
	var _stories: [StoryModel]! {
		return getStoriesFromMock()
	}
	var _currentStoryIndex = StoryIndex()
	var backgroundViewException: XCTestExpectation!
	var swipeGestureRecognizerException: XCTestExpectation!
	var hideGestureRecognizerException: XCTestExpectation!
	var fullScreenDidTapOnCloseButtonException: XCTestExpectation!
	var fullScreenStoriesDidEndException: XCTestExpectation!
	var showStoryException: XCTestExpectation!
	var preloadNextStoryException: XCTestExpectation!
	var preloadPrevStoryException: XCTestExpectation!
	var startInteractiveTransitionException: XCTestExpectation!
	var didShowStoryWithImageException: XCTestExpectation!
	var didShowStoryWithVideoOrTrackException: XCTestExpectation!
	var didTapOnButtonWithUrlExpectation: XCTestExpectation!
	var showInitialStoryExpectation: XCTestExpectation!
	
    override func setUp() {
		super.setUp()
		presenter = FullScreenPresenter(view: self, storiesService: self, output: self)
    }

    override func tearDown() {
		backgroundViewException = nil
		swipeGestureRecognizerException = nil
		hideGestureRecognizerException = nil
		fullScreenDidTapOnCloseButtonException = nil
		fullScreenStoriesDidEndException = nil
		showStoryException = nil
		preloadNextStoryException = nil
		preloadPrevStoryException = nil
		startInteractiveTransitionException = nil
		didShowStoryWithImageException = nil
		didShowStoryWithVideoOrTrackException = nil
		didTapOnButtonWithUrlExpectation = nil
		showInitialStoryExpectation = nil
		super.tearDown()
    }

    func testViewDidLoad() {
		backgroundViewException = expectation(description: "BackgroundView added to view")
		swipeGestureRecognizerException = expectation(description: "SwipeGestureRecognizer added to view")
		hideGestureRecognizerException = expectation(description: "HideGestureRecognizer added to view")
		
		presenter.viewDidLoad()
		
		wait(for: [swipeGestureRecognizerException,
				   backgroundViewException,
				   hideGestureRecognizerException],
			 timeout: waitTimeout)
    }
	
	func testCloseButtonDidTap() {
		fullScreenDidTapOnCloseButtonException = expectation(description: "FullScreen did tap on close button")
		
		presenter.closeButtonDidTap()
		
		wait(for: [fullScreenDidTapOnCloseButtonException],
			 timeout: waitTimeout)
	}
	
	func testNeedShowNextStory() {
		fullScreenStoriesDidEndException = expectation(description: "Истории закончились")
		_currentStoryIndex.storyIndex = _stories.count - 1
		
		presenter.needShowNextStory()
		
		wait(for: [fullScreenStoriesDidEndException],
			 timeout: waitTimeout)
		
		let storyIndex = 0
		_currentStoryIndex.storyIndex = storyIndex
		showStoryException = expectation(description: "Должна быть показана история")
		preloadNextStoryException = expectation(description: "Должна выполниться предзагрузка слеующей истории")

		presenter.needShowNextStory()

		XCTAssertEqual(storyIndex + 1, _currentStoryIndex.storyIndex, "storyIndex не инкрементировался")
		wait(for: [showStoryException,
				   preloadNextStoryException],
			 timeout: waitTimeout)
	}
	
	func testNeedShowPrevStory() {
		fullScreenStoriesDidEndException = expectation(description: "Истории закончились")
		_currentStoryIndex.storyIndex = 0
		
		presenter.needShowPrevStory()
		
		wait(for: [fullScreenStoriesDidEndException],
			 timeout: waitTimeout)
		
		let storyIndex = _stories.count - 1
		_currentStoryIndex.storyIndex = storyIndex
		showStoryException = expectation(description: "Должна быть показана история")
		preloadPrevStoryException = expectation(description: "Должна выполниться предзагрузка предыдущей истории")
		
		presenter.needShowPrevStory()
		
		XCTAssertEqual(storyIndex - 1, _currentStoryIndex.storyIndex, "storyIndex не был декрементирован")
		wait(for: [showStoryException,
				   preloadPrevStoryException],
			 timeout: waitTimeout)
	}
	
	func testPanGestureRecognizerBegan() {
		//тест случая когда свайпаем с лева на право на первой истории
		fullScreenStoriesDidEndException = expectation(description: "Истории закончились")
		_currentStoryIndex.storyIndex = 0
		
		presenter.panGestureRecognizerBegan(direction: .leftToRight)
		
		wait(for: [fullScreenStoriesDidEndException],
			 timeout: waitTimeout)
		
		//тест случая когда свайпаем с лева на право любую историю кроме первой
		startInteractiveTransitionException = expectation(description: "Ожидается вызов начала интерактивного перехода")
		_currentStoryIndex.storyIndex = _stories.count - 1
		
		presenter.panGestureRecognizerBegan(direction: .leftToRight)
		
		wait(for: [startInteractiveTransitionException],
			 timeout: waitTimeout)
		
		//тест случая когда свайпаем с права на лево на последней истории
		fullScreenStoriesDidEndException = nil
		fullScreenStoriesDidEndException = expectation(description: "Истории закончились")
		_currentStoryIndex.storyIndex = _stories.count - 1
		
		presenter.panGestureRecognizerBegan(direction: .rightToLeft)
		
		wait(for: [fullScreenStoriesDidEndException],
			 timeout: waitTimeout)
		
		//тест случая когда свайпаем с права на лево любую историю кроме первой
		startInteractiveTransitionException = expectation(description: "Ожидается вызов начала интерактивного перехода")
		_currentStoryIndex.storyIndex = 0
		
		presenter.panGestureRecognizerBegan(direction: .rightToLeft)
		
		wait(for: [startInteractiveTransitionException],
			 timeout: waitTimeout)
	}
	
	func testInteractiveTransitionDidEnd() {
		//тест случая когда заканчиваем свайп с лева на право
		preloadPrevStoryException = expectation(description: "Должна выполниться предзагрузка предыдущей истории")
		var storyIndex = _stories.count - 1
		_currentStoryIndex.storyIndex = storyIndex
		
		presenter.interactiveTransitionDidEnd(direction: .leftToRight)
		
		XCTAssertEqual(storyIndex - 1, _currentStoryIndex.storyIndex, "storyIndex не был декрементирован")
		wait(for: [preloadPrevStoryException],
			 timeout: waitTimeout)
		
		//тест случая когда заканчиваем свайп с права на лево
		preloadNextStoryException = expectation(description: "Должна выполниться предзагрузка следующей истории")
		storyIndex = 0
		_currentStoryIndex.storyIndex = storyIndex
		
		presenter.interactiveTransitionDidEnd(direction: .rightToLeft)
		
		XCTAssertEqual(storyIndex + 1, _currentStoryIndex.storyIndex, "storyIndex не был инкрементирован")
		wait(for: [preloadNextStoryException],
			 timeout: waitTimeout)
	}
//
	func testDidShowStoryWithImage() {
		didShowStoryWithImageException = expectation(description: "Была показана история с картинкой")
		
		presenter.didShowStoryWithImage()
		
		wait(for: [didShowStoryWithImageException],
			 timeout: waitTimeout)
	}
//
	func testDidShowStoryWithVideoOrTrack() {
		didShowStoryWithVideoOrTrackException = expectation(description: "Была показана история с видео контентом или музыкальным треком")
		
		presenter.didShowStoryWithVideoOrTrack()
		
		wait(for: [didShowStoryWithVideoOrTrackException],
			 timeout: waitTimeout)
	}
//
	func testDidTapOnButton() {
		didTapOnButtonWithUrlExpectation = expectation(description: "Была нажата кнопка при нажатии на которую должен обработаться диплинк")
		
		presenter.didTapOnButton(url: URL(string: "https://yandex.ru")!)
		
		wait(for: [didTapOnButtonWithUrlExpectation],
			 timeout: waitTimeout)
	}
	
	func testSetSelectedStory() {
		// тест показа первой истории
		showInitialStoryExpectation = expectation(description: "Была показана первая история")
		preloadNextStoryException = expectation(description: "Должна выполниться предзагрузка слеующей истории")
		
		var selectedStoryIndex = 0
		presenter.setSelectedStory(index: selectedStoryIndex)
		
		XCTAssertEqual(selectedStoryIndex, currentStoryIndex.storyIndex, "Индексы историй должны совпадать")
		wait(for: [showInitialStoryExpectation, preloadNextStoryException],
			 timeout: waitTimeout)
		
		// тест случая когда передаваемый индекс больше количества историй в массиве stories типа [StoryModel]
		selectedStoryIndex = _stories.count
		presenter.setSelectedStory(index: selectedStoryIndex)
		
		XCTAssertEqual(selectedStoryIndex, currentStoryIndex.storyIndex, "Индексы историй должны совпадать")
	}
}

extension FullScreenPresenterTest: FullScreenViewInput {
	func addBackgroundView() {
		backgroundViewException?.fulfill()
	}
	
	func addSwipeGestureRecognizer() {
		swipeGestureRecognizerException?.fulfill()
	}
	
	func addHideGestureRecognizer() {
		hideGestureRecognizerException?.fulfill()
	}
	
	func showStory(storyModel: StoryModel, direction: Direction) {
		showStoryException.fulfill()
	}
	
	func showInitialStory(storyModel: StoryModel) {
		showInitialStoryExpectation.fulfill()
	}
	
	func startInteractiveTransition(storyModel: StoryModel) {
		startInteractiveTransitionException.fulfill()
	}
}

extension FullScreenPresenterTest: StoriesServiceInput {
	var currentStoryIndex: StoryIndex {
		get {
			return _currentStoryIndex
		}
		set(newValue) {
			_currentStoryIndex = newValue
		}
	}
	
	var stories: [StoryModel]? {
		return _stories
	}
	
	func getStories(success: Success?, failure: Failure?) {
		
	}
	
	func getData(_ slideModel: SlideModel, success: Success?, failure: Failure?) {
		
	}
	
	func preDownloadStory(storyModel: StoryModel) {
		
	}
	
	func addDownloadQueue(slideModel: SlideModel) {
		
	}
	
	func prevStory() -> StoryModel? {
		if let stories = stories,
			stories.count > currentStoryIndex.storyIndex,
			currentStoryIndex.storyIndex - 1 >= 0 {
			return stories[currentStoryIndex.storyIndex - 1]
		}
		return nil
	}
	
	func nextStory() -> StoryModel? {
		if let stories = stories,
			stories.count > currentStoryIndex.storyIndex + 1 {
			return stories[currentStoryIndex.storyIndex + 1]
		}
		return nil
	}
	
	func preloadNextStory() {
		preloadNextStoryException.fulfill()
	}
	
	func preloadPreviousStory() {
		preloadPrevStoryException.fulfill()
	}
	
	func preloadNextSlide() {
	}
}

extension FullScreenPresenterTest: FullScreenModuleOutput {
	func fullScreenDidTapOnCloseButton(storyIndex: Int) {
		fullScreenDidTapOnCloseButtonException.fulfill()
	}
	
	func fullScreenStoriesDidEnd(storyIndex: Int) {
		fullScreenStoriesDidEndException.fulfill()
	}
	
	func didShowStoryWithImage() {
		didShowStoryWithImageException.fulfill()
	}
	
	func didShowStoryWithVideoOrTrack() {
		didShowStoryWithVideoOrTrackException.fulfill()
	}
	
	func didTapOnButton(url: URL, storyIndex: Int) {
		didTapOnButtonWithUrlExpectation.fulfill()
	}
}

extension FullScreenPresenterTest {
	func getStoriesFromMock() -> [StoryModel]? {
		guard let path = Bundle(for: FullScreenPresenterTest.self).path(forResource: "storiesMock.json", ofType: nil),
			let data = FileManager.default.contents(atPath: path),
			let stories = try? JSONDecoder().decode(StoriesModel.self, from: data) else { return nil }
		return stories.stories
	}
}

