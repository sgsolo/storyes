
import XCTest
@testable import StoriesSDK

class StoryServiceTest: XCTestCase {

	var storiesService: StoriesService!
	var apiClient: ApiClientStub!
	
    override func setUp() {
		super.setUp()
		apiClient = ApiClientStub()
		storiesService = StoriesService(apiClient: apiClient)
    }

    override func tearDown() {
		super.tearDown()
    }

	func testGetStories() {
		// тест случая удачного получения сториз
		apiClient.apiClientBehavior = .success
		storiesService = StoriesService(apiClient: apiClient)
		let storiesExpectation = expectation(description: "Ожидание получения сториз")
		XCTAssertNil(storiesService.stories)
		
		storiesService.getStories(completion: { result in
			switch result {
			case .success(_):
				storiesExpectation.fulfill()
			case .failure(_):
				XCTFail("Expected success case, got failure")
			}
		})
		
		wait(for: [storiesExpectation], timeout: waitTimeout)
		XCTAssertNotNil(storiesService.stories)
		
		// тест случая получения ошибки сети
		apiClient.apiClientBehavior = .invalidData
		storiesService = StoriesService(apiClient: apiClient)
		var errorExpectation = expectation(description: "Ожидание получения не валидных данных с апи")
		storiesService.getStories(completion: { result in
			switch result {
			case .success(_):
				XCTFail("Expected failure case, got success")
			case .failure(_):
				errorExpectation.fulfill()
			}
		})
		
		wait(for: [errorExpectation], timeout: waitTimeout)
		XCTAssertNil(storiesService.stories)
		
		// тест случая получения ошибки сети
		apiClient.apiClientBehavior = .networkError
		storiesService = StoriesService(apiClient: apiClient)
		errorExpectation = expectation(description: "Ожидание получения ошибки сети")
		storiesService.getStories(completion: { result in
			switch result {
			case .success(_):
				XCTFail("Expected failure case, got success")
			case .failure(_):
				errorExpectation.fulfill()
			}
		})
		
		wait(for: [errorExpectation], timeout: waitTimeout)
		XCTAssertNil(storiesService.stories)
	}
	
	func testGetDataFromSlideModel() {
		var getDataExpectation: XCTestExpectation!
		var errorExpectation: XCTestExpectation!
		var slideViewModel: SlideViewModel?
		
		//Тест кейс 1
		apiClient.apiClientBehavior = .success
		getDataExpectation = expectation(description: "Ожидается вызов метода получения дынных по урлу apiClient'а")
		var slideModel = SlideModel(slideDuration: 0,
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
									animationType: nil)
		
		storiesService.getData(slideModel) { result in
			switch result {
			case .success(let viewModel):
				slideViewModel = viewModel
				getDataExpectation.fulfill()
			case .failure(_):
				XCTFail("Expected success case, got failure")
			}
		}
		
		wait(for: [getDataExpectation], timeout: waitTimeout)
		XCTAssertEqual(slideViewModel?.videoUrl, URL(string: yandexUrlString)!, "Urls must be equal")
		XCTAssertEqual(slideViewModel?.type, .video, "SlideViewContentTypes must be equal")
		
		//Тест кейс 2
		slideViewModel = nil
		apiClient.apiClientBehavior = .networkError
		errorExpectation = expectation(description: "Ожидание получения ошибки сети")
		
		storiesService.getData(slideModel) { result in
			switch result {
			case .success(_):
				XCTFail("Expected failure case, got success")
			case .failure(_):
				errorExpectation.fulfill()
			}
		}
		
		wait(for: [errorExpectation], timeout: waitTimeout)
		
		//Тест кейс 3
		slideViewModel = nil
		apiClient.apiClientBehavior = .success
		getDataExpectation = expectation(description: "Ожидается вызов метода получения дынных по урлу apiClient'а")
		slideModel = SlideModel(slideDuration: 0,
								player: nil,
								track: Track(trackName: nil,
											 trackArtist: nil,
											 durationMs: nil,
											 storageDir: yandexUrlString),
								video: nil,
								image: yandexUrlString,
								frontImage: nil,
								buttonURL: nil,
								contentStyle: false,
								description: nil,
								title3: nil,
								title2: nil,
								title: "",
								buttonText: nil,
								buttonStyle: nil,
								animationType: nil)
		
		storiesService.getData(slideModel) { result in
			switch result {
			case .success(let viewModel):
				slideViewModel = viewModel
				getDataExpectation.fulfill()
			case .failure(_):
				XCTFail("Expected success case, got failure")
			}
		}
		
		wait(for: [getDataExpectation], timeout: waitTimeout)
		XCTAssertEqual(slideViewModel?.trackUrl, URL(string: yandexUrlString)!, "Urls must be equal")
		XCTAssertEqual(slideViewModel?.imageUrl, URL(string: yandexUrlString)!, "Urls must be equal")
		XCTAssertEqual(slideViewModel?.videoUrl, nil, "Urls must be equal")
		XCTAssertEqual(slideViewModel?.type, .track, "SlideViewContentTypes must be equal")
		
		//Тест кейс 4
		slideViewModel = nil
		apiClient.apiClientBehavior = .networkError
		errorExpectation = expectation(description: "Ожидание получения ошибки сети")
		
		storiesService.getData(slideModel) { result in
			switch result {
			case .success(_):
				XCTFail("Expected failure case, got success")
			case .failure(_):
				errorExpectation.fulfill()
			}
		}
		
		wait(for: [errorExpectation], timeout: waitTimeout)
		
		//Тест кейс 5
		slideViewModel = nil
		apiClient.apiClientBehavior = .success
		getDataExpectation = expectation(description: "Ожидается вызов метода получения дынных по урлу apiClient'а")
		slideModel = SlideModel(slideDuration: 0,
								player: nil,
								track: Track(trackName: nil,
											 trackArtist: nil,
											 durationMs: nil,
											 storageDir: yandexUrlString),
								video: nil,
								image: yandexUrlString,
								frontImage: yandexUrlString,
								buttonURL: nil,
								contentStyle: false,
								description: nil,
								title3: nil,
								title2: nil,
								title: "",
								buttonText: nil,
								buttonStyle: nil,
								animationType: nil)
		
		storiesService.getData(slideModel) { result in
			switch result {
			case .success(let viewModel):
				slideViewModel = viewModel
				getDataExpectation.fulfill()
			case .failure(_):
				XCTFail("Expected success case, got failure")
			}
		}
		
		wait(for: [getDataExpectation], timeout: waitTimeout)
		XCTAssertEqual(slideViewModel?.trackUrl, URL(string: yandexUrlString)!, "Urls must be equal")
		XCTAssertEqual(slideViewModel?.imageUrl, URL(string: yandexUrlString)!, "Urls must be equal")
		XCTAssertEqual(slideViewModel?.frontImageUrl, URL(string: yandexUrlString)!, "Urls must be equal")
		XCTAssertEqual(slideViewModel?.videoUrl, nil, "Urls must be equal")
		XCTAssertEqual(slideViewModel?.type, .track, "SlideViewContentTypes must be equal")
		
		//Тест кейс 6
		slideViewModel = nil
		apiClient.apiClientBehavior = .networkError
		errorExpectation = expectation(description: "Ожидание получения ошибки сети")
		slideModel = SlideModel(slideDuration: 0,
								player: nil,
								track: nil,
								video: nil,
								image: nil,
								frontImage: yandexUrlString,
								buttonURL: nil,
								contentStyle: false,
								description: nil,
								title3: nil,
								title2: nil,
								title: "",
								buttonText: nil,
								buttonStyle: nil,
								animationType: nil)
		
		storiesService.getData(slideModel) { result in
			switch result {
			case .success(_):
				XCTFail("Expected failure case, got success")
			case .failure(_):
				errorExpectation.fulfill()
			}
		}
		
		wait(for: [errorExpectation], timeout: waitTimeout)
		
		//Тест кейс 7
		slideViewModel = nil
		apiClient.apiClientBehavior = .success
		getDataExpectation = expectation(description: "Ожидается вызов метода получения дынных по урлу apiClient'а")
		slideModel = SlideModel(slideDuration: 0,
								player: nil,
								track: nil,
								video: nil,
								image: yandexUrlString,
								frontImage: yandexUrlString,
								buttonURL: nil,
								contentStyle: false,
								description: nil,
								title3: nil,
								title2: nil,
								title: "",
								buttonText: nil,
								buttonStyle: nil,
								animationType: nil)
		
		storiesService.getData(slideModel) { result in
			switch result {
			case .success(let viewModel):
				slideViewModel = viewModel
				getDataExpectation.fulfill()
			case .failure(_):
				XCTFail("Expected success case, got failure")
			}
		}
		
		wait(for: [getDataExpectation], timeout: waitTimeout)
		XCTAssertEqual(slideViewModel?.trackUrl, nil, "Urls must be equal")
		XCTAssertEqual(slideViewModel?.imageUrl, URL(string: yandexUrlString)!, "Urls must be equal")
		XCTAssertEqual(slideViewModel?.frontImageUrl, URL(string: yandexUrlString)!, "Urls must be equal")
		XCTAssertEqual(slideViewModel?.videoUrl, nil, "Urls must be equal")
		XCTAssertEqual(slideViewModel?.type, .image, "SlideViewContentTypes must be equal")
		
		//Тест кейс 8
		slideViewModel = nil
		apiClient.apiClientBehavior = .networkError
		errorExpectation = expectation(description: "Ожидание получения ошибки сети")
		slideModel = SlideModel(slideDuration: 0,
								player: nil,
								track: nil,
								video: nil,
								image: yandexUrlString,
								frontImage: yandexUrlString,
								buttonURL: nil,
								contentStyle: false,
								description: nil,
								title3: nil,
								title2: nil,
								title: "",
								buttonText: nil,
								buttonStyle: nil,
								animationType: nil)
		
		storiesService.getData(slideModel) { result in
			switch result {
			case .success(_):
				XCTFail("Expected failure case, got success")
			case .failure(_):
				errorExpectation.fulfill()
			}
		}
		
		wait(for: [errorExpectation], timeout: waitTimeout)
	}
	
	func testPreviousStory() {
		var storyModel: StoryModel?
		//Test 1
		apiClient.apiClientBehavior = .success
		storiesService.getStories(completion: { _ in })
		storiesService.currentStoryIndex.storyIndex = 0
		
		storyModel = storiesService.prevStory()
		
		XCTAssertNil(storyModel)
		
		//Test 2
		apiClient.apiClientBehavior = .success
		storiesService.getStories(completion: { _ in })
		(1...storiesService.stories!.count - 1).forEach { item in
			storiesService.currentStoryIndex.storyIndex = item
			
			storyModel = storiesService.prevStory()
			
			XCTAssertNotNil(storyModel, "StoryModel cannot be nil")
		}
	}
	
	func testNextStory() {
		var storyModel: StoryModel?
		//Test 1
		apiClient.apiClientBehavior = .success
		storiesService.getStories(completion: { _ in })
		(0...storiesService.stories!.count - 2).forEach { item in
			storiesService.currentStoryIndex.storyIndex = item
			
			storyModel = storiesService.nextStory()
			
			XCTAssertNotNil(storyModel, "StoryModel cannot be nil")
		}
		
		//Test 2
		apiClient.apiClientBehavior = .success
		storiesService.getStories(completion: { _ in })
		storiesService.currentStoryIndex.storyIndex = storiesService.stories!.count - 1
		
		storyModel = storiesService.nextStory()
		
		XCTAssertNil(storyModel)
	}
	
	func testPreloadNextSlide() {
		apiClient.apiClientBehavior = .success
		storiesService.getStories(completion: { _ in })
		storiesService.currentStoryIndex.storyIndex = 0
		var getDataExpectation = expectation(description: "Ожидается вызов метода получения дынных по урлу apiClient'а")
		
		apiClient.didCall_GetDataUrlCompletion = { _, _ in
			getDataExpectation.fulfill()
		}
		storiesService.preloadNextSlide()
		
		wait(for: [getDataExpectation], timeout: waitTimeout)
		
		apiClient.apiClientBehavior = .success
		storiesService.getStories(completion: { _ in })
		storiesService.currentStoryIndex.storyIndex = storiesService.stories!.count
//		getDataExpectation = expectation(description: "Ожидается вызов метода получения дынных по урлу apiClient'а")
		
//		apiClient.didCall_GetDataUrlCompletion = { _, _ in
//			getDataExpectation.fulfill()
//		}
		storiesService.preloadNextSlide()
		
//		wait(for: [getDataExpectation], timeout: waitTimeout)
	}
}

final class ApiClientStub: ApiClientInput {
	enum ApiClientBehavior {
		case success
		case invalidData
		case networkError
	}
	
	var apiClientBehavior: ApiClientBehavior = .success
	
	func getStories(completion: @escaping (Result<Data, Error>) -> Void) {
		switch apiClientBehavior {
		case .success:
			let data = getStoriesData()
			if let data = data {
				completion(.success(data))
			}
		case .invalidData:
			let data = getInvalidData()
			if let data = data {
				completion(.success(data))
			}
		case .networkError:
			let error = NSError(domain: "", code: 0, userInfo: nil)
			completion(.failure(error))
		}
	}
	
	var didCall_GetDataUrlCompletion: ((URL, (Result<URL, Error>) -> Void) -> Void)?
	
	func getData(_ url: URL, completion: @escaping (Result<URL, Error>) -> Void) {
		didCall_GetDataUrlCompletion?(url, completion)
		switch apiClientBehavior {
		case .success:
			completion(.success(URL(string: yandexUrlString)!))
		case .networkError:
			let error = NSError(domain: "", code: 0, userInfo: nil)
			completion(.failure(error))
		default:
			break
		}
	}
	
	private func getStoriesData() -> Data? {
		guard let path = Bundle(for: FullScreenPresenterTest.self).path(forResource: "storiesMock.json", ofType: nil) else { return nil }
		return FileManager.default.contents(atPath: path)
	}
	
	private func getInvalidData() -> Data? {
		guard let path = Bundle(for: FullScreenPresenterTest.self).path(forResource: "invalidStoriesMock.json", ofType: nil) else { return nil }
		return FileManager.default.contents(atPath: path)
	}
}
