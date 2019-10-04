
import XCTest
@testable import StoriesSDK

class ApiServiceTest: XCTestCase {

	var urlSessionMock: URLSessionMock!
	var cacheServiceMock: CacheServiceMock!
	var apiClient: ApiServiceInput!
	
    override func setUp() {
		super.setUp()
		YStoriesManager.needUseMockData = false
		urlSessionMock = URLSessionMock()
		cacheServiceMock = CacheServiceMock()
		apiClient = ApiService(urlSession: urlSessionMock, cacheService: cacheServiceMock)
    }

    override func tearDown() {
		super.tearDown()
		YStoriesManager.needUseMockData = false
		urlSessionMock = nil
		cacheServiceMock = nil
		apiClient = nil
	}

    func testGetRequest() {
		var dataExpectation: XCTestExpectation!
		
		//test 1
		dataExpectation = expectation(description: "Data expectation")
		YStoriesManager.needUseMockData = true
		
		apiClient.getStories { result in
			switch result {
			case .success(_):
				dataExpectation.fulfill()
			case .failure(_):
				XCTFail("")
			}
		}
		
		wait(for: [dataExpectation], timeout: waitTimeout)
		
		//test 2
		dataExpectation = expectation(description: "Data expectation")
		YStoriesManager.needUseMockData = false
		urlSessionMock.state = .success
		
		apiClient.getStories { result in
			switch result {
			case .success(_):
				dataExpectation.fulfill()
			case .failure(_):
				XCTFail("")
			}
		}
		
		wait(for: [dataExpectation], timeout: waitTimeout)
		
		//test 3
		dataExpectation = expectation(description: "Data expectation")
		YStoriesManager.needUseMockData = false
		urlSessionMock.state = .invalidStatusCode
		
		apiClient.getStories { result in
			switch result {
			case .success(_):
				XCTFail("")
			case .failure(_):
				dataExpectation.fulfill()
			}
		}
		
		wait(for: [dataExpectation], timeout: waitTimeout)
		
		//test 4
		dataExpectation = expectation(description: "Data expectation")
		YStoriesManager.needUseMockData = false
		urlSessionMock.state = .error
		
		apiClient.getStories { result in
			switch result {
			case .success(_):
				XCTFail("")
			case .failure(_):
				dataExpectation.fulfill()
			}
		}
		
		wait(for: [dataExpectation], timeout: waitTimeout)
    }
	
	func testGetData() {
		var dataExpectation: XCTestExpectation!
		var getUrlWithStringUrlCallCount = 0
		
		//тест случая когда данные загружаются но не сохраняются в кэш
		dataExpectation = expectation(description: "Data expectation")
		urlSessionMock.state = .success
		
		apiClient.getData(URL(string: yandexUrlString)!) { result in
			switch result {
			case .success(_):
				XCTFail("")
			case .failure(_):
				dataExpectation.fulfill()
			}
		}
		
		wait(for: [dataExpectation], timeout: waitTimeout)
		
		//тест случая когда приходят сетевые ошибки
		dataExpectation = expectation(description: "Data expectation")
		urlSessionMock.state = .error
		
		apiClient.getData(URL(string: yandexUrlString)!) { result in
			switch result {
			case .success(_):
				XCTFail("")
			case .failure(_):
				dataExpectation.fulfill()
			}
		}
		
		wait(for: [dataExpectation], timeout: waitTimeout)
		
		//тест случая когда выполняются одновременно 2 запроса к 1 и тому же ресурсу удачно
		dataExpectation = expectation(description: "Data expectation")
		dataExpectation.expectedFulfillmentCount = 2
		urlSessionMock.state = .success
		cacheServiceMock.didCall_getUrlWithStringUrl = {
			getUrlWithStringUrlCallCount += 1
			if getUrlWithStringUrlCallCount >= 3 {
				return URL(string: yandexUrlString)
			}
			return nil
		}
		cacheServiceMock.didCall_saveToCacheIfNeeded = {
			return URL(string: yandexUrlString)
		}
		
		apiClient.getData(URL(string: yandexUrlString)!) { result in
			switch result {
			case .success(_):
				dataExpectation.fulfill()
			case .failure(_):
				XCTFail("")
			}
		}
		apiClient.getData(URL(string: yandexUrlString)!) { result in
			switch result {
			case .success(_):
				dataExpectation.fulfill()
			case .failure(_):
				XCTFail("")
			}
		}
		
		wait(for: [dataExpectation], timeout: waitTimeout)
		
		//тест случая когда выполняются одновременно 2 запроса к 1 и тому же ресурсу, при  этом данные не сохраняются в кэш
		dataExpectation = expectation(description: "Data expectation")
		dataExpectation.expectedFulfillmentCount = 2
		urlSessionMock.state = .success
		getUrlWithStringUrlCallCount = 0
		cacheServiceMock.didCall_getUrlWithStringUrl = {
			return nil
		}
		cacheServiceMock.didCall_saveToCacheIfNeeded = {
			return nil
		}
		
		apiClient.getData(URL(string: yandexUrlString)!) { result in
			switch result {
			case .success(_):
				XCTFail("")
			case .failure(_):
				dataExpectation.fulfill()
			}
		}
		apiClient.getData(URL(string: yandexUrlString)!) { result in
			switch result {
			case .success(_):
				XCTFail("")
			case .failure(_):
				dataExpectation.fulfill()
			}
		}
		
		wait(for: [dataExpectation], timeout: waitTimeout)
		
		//тест случая когда выполняется запрос при  этом данные не сохраняются в кэш
		dataExpectation = expectation(description: "Data expectation")
		urlSessionMock.state = .success
		cacheServiceMock.didCall_getUrlWithStringUrl = {
			return nil
		}
		cacheServiceMock.didCall_saveToCacheIfNeeded = {
			return nil
		}
		
		apiClient.getData(URL(string: yandexUrlString)!) { result in
			switch result {
			case .success(_):
				XCTFail("")
			case .failure(_):
				dataExpectation.fulfill()
			}
		}
		
		wait(for: [dataExpectation], timeout: waitTimeout)
		
		//тест случая когда данные возвращаются с кэша
		dataExpectation = expectation(description: "Data expectation")
		urlSessionMock.state = .success
		cacheServiceMock.didCall_getUrlWithStringUrl = {
			return URL(string: yandexUrlString)
		}
		
		apiClient.getData(URL(string: yandexUrlString)!) { result in
			switch result {
			case .success(_):
				dataExpectation.fulfill()
			case .failure(_):
				XCTFail("")
			}
		}
		
		wait(for: [dataExpectation], timeout: waitTimeout)
	}
}

final class CacheServiceMock: CacheServiceInput {
	func getViewModel(slideModel: SlideModel) -> SlideViewModel? {
		return nil
	}
	
	var didCall_getUrlWithStringUrl: (() -> URL?)?
	
	func getUrlWith(stringUrl: String) -> URL? {
		let url = didCall_getUrlWithStringUrl?()
		return url
	}
	
	var didCall_saveToCacheIfNeeded: (() -> URL?)?
	
	func saveToCacheIfNeeded(_ url: URL, currentLocation: URL) -> URL? {
		let url = didCall_saveToCacheIfNeeded?()
		return url
	}
}

final class URLSessionMock: URLSession {
	enum URLSessionMockState {
		case success
		case invalidStatusCode
		case error
	}
	
	var state: URLSessionMockState = .success
	
	override func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
		let resumeBlock = {
			switch self.state {
			case .success:
				let urlResponse = HTTPURLResponse(url: URL(string: yandexUrlString)!,
												  statusCode: 200,
												  httpVersion: nil, headerFields: nil)
				completionHandler(self.getStoriesData(), urlResponse, nil)
			case .invalidStatusCode:
				let urlResponse = HTTPURLResponse(url: URL(string: yandexUrlString)!,
												  statusCode: 400,
												  httpVersion: nil, headerFields: nil)
				completionHandler(self.getStoriesData(), urlResponse, nil)
				break
			case .error:
				let error = NSError(domain: "some error", code: 0, userInfo: nil)
				completionHandler(self.getStoriesData(), nil, error)
			}
		}
		return URLSessionDataTaskMock(resumeBlock: resumeBlock)
	}
	
	override func downloadTask(with url: URL, completionHandler: @escaping (URL?, URLResponse?, Error?) -> Void) -> URLSessionDownloadTask {
		let resumeBlock = {
			switch self.state {
			case .success:
				let urlResponse = HTTPURLResponse(url: URL(string: yandexUrlString)!,
												  statusCode: 200,
												  httpVersion: nil, headerFields: nil)
				completionHandler(URL(string: yandexUrlString)!, urlResponse, nil)
			case .invalidStatusCode:
				let urlResponse = HTTPURLResponse(url: URL(string: yandexUrlString)!,
												  statusCode: 400,
												  httpVersion: nil, headerFields: nil)
				completionHandler(URL(string: yandexUrlString)!, urlResponse, nil)
				break
			case .error:
				let error = NSError(domain: "some error", code: 0, userInfo: nil)
				completionHandler(URL(string: yandexUrlString)!, nil, error)
			}
		}
		return URLSessionDownloadTaskMock(resumeBlock: resumeBlock)
	}
	
	private func getStoriesData() -> Data? {
		guard let path = Bundle(for: FullScreenPresenterTest.self).path(forResource: "storiesMock.json", ofType: nil) else { return nil }
		return FileManager.default.contents(atPath: path)
	}
}

final class URLSessionDataTaskMock: URLSessionDataTask {
	
	let resumeBlock: () -> Void
	
	init(resumeBlock: @escaping () -> Void) {
		self.resumeBlock = resumeBlock
		super.init()
	}
	
	override func resume() {
		resumeBlock()
	}
	
	override func cancel() {}
}

final class URLSessionDownloadTaskMock: URLSessionDownloadTask {
	
	let resumeBlock: () -> Void
	
	init(resumeBlock: @escaping () -> Void) {
		self.resumeBlock = resumeBlock
		super.init()
	}
	
	override func resume() {
		resumeBlock()
	}
	
	override func cancel() {}
}
