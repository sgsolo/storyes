
import XCTest
@testable import StoriesSDK

class CacheServiceTest: XCTestCase {

	var fileManager: FileManagerMock!
	var cacheService: CacheServiceInput!
	
    override func setUp() {
		super.setUp()
		fileManager = FileManagerMock()
		cacheService = CacheService(fileManager: fileManager)
	}

    override func tearDown() {
		super.tearDown()
	}

	func testGetViewModel() {
		var slideViewModel: SlideViewModel?
		
		//Тест кейс 1
		//		getDataExpectation = expectation(description: "Ожидается вызов метода получения дынных по урлу apiClient'а")
		fileManager.state = .hasData
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
		
		slideViewModel = cacheService.getViewModel(slideModel: slideModel)
		
		XCTAssertEqual(slideViewModel?.type, .video, "SlideViewContentTypes must be equal")
		XCTAssertNotNil(slideViewModel?.videoUrl, "videoUrl must not be nil")
		XCTAssertNil(slideViewModel?.trackUrl, "trackUrl must be nil")
		XCTAssertNil(slideViewModel?.imageUrl, "imageUrl must be nil")
		
		//Тест кейс 2
		slideViewModel = nil
		//		errorExpectation = expectation(description: "Ожидание получения ошибки сети")
		fileManager.state = .hasNoData
		
		slideViewModel = cacheService.getViewModel(slideModel: slideModel)
		
		XCTAssertNil(slideViewModel, "slideViewModel must be nil")
		//		wait(for: [errorExpectation], timeout: waitTimeout)
		
		//Тест кейс 3
		slideViewModel = nil
		fileManager.state = .hasData
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
		
		slideViewModel = cacheService.getViewModel(slideModel: slideModel)
		
		XCTAssertNotNil(slideViewModel?.trackUrl, "trackUrl must be nil")
		XCTAssertNotNil(slideViewModel?.imageUrl, "imageUrl must be nil")
		XCTAssertNil(slideViewModel?.videoUrl, "videoUrl must be nil")
		XCTAssertEqual(slideViewModel?.type, .track, "SlideViewContentTypes must be equal")
		
		//Тест кейс 4
		slideViewModel = nil
		fileManager.state = .hasNoData
		
		slideViewModel = cacheService.getViewModel(slideModel: slideModel)
		
		XCTAssertNil(slideViewModel, "slideViewModel must be nil")
		
		//Тест кейс 5
		slideViewModel = nil
		fileManager.state = .hasData
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
		
		slideViewModel = cacheService.getViewModel(slideModel: slideModel)
		
		XCTAssertNotNil(slideViewModel?.trackUrl, "Urls must be not nil")
		XCTAssertNotNil(slideViewModel?.imageUrl, "Urls must be not nil")
		XCTAssertNotNil(slideViewModel?.frontImageUrl, "Urls must be not nil")
		XCTAssertNil(slideViewModel?.videoUrl, "Urls must be nil")
		XCTAssertEqual(slideViewModel?.type, .track, "SlideViewContentTypes must be equal")
		
		//Тест кейс 6
		slideViewModel = nil
		fileManager.state = .hasNoData
		
		slideViewModel = cacheService.getViewModel(slideModel: slideModel)
		
		XCTAssertNil(slideViewModel, "slideViewModel must be nil")
		
		//Тест кейс 7
		slideViewModel = nil
		fileManager.state = .hasData
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
		
		slideViewModel = cacheService.getViewModel(slideModel: slideModel)
		
		XCTAssertNil(slideViewModel?.trackUrl, "Urls must be equal")
		XCTAssertNil(slideViewModel?.imageUrl, "Urls must be equal")
		XCTAssertNotNil(slideViewModel?.frontImageUrl, "Urls must be equal")
		XCTAssertNil(slideViewModel?.videoUrl, "Urls must be equal")
		XCTAssertEqual(slideViewModel?.type, .image, "SlideViewContentTypes must be equal")
		
		//Тест кейс 8
		slideViewModel = nil
		fileManager.state = .hasNoData
		
		slideViewModel = cacheService.getViewModel(slideModel: slideModel)
		
		XCTAssertNil(slideViewModel, "slideViewModel must be nil")
		
		//Тест кейс 9
		slideViewModel = nil
		fileManager.state = .hasNoData
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
		
		slideViewModel = cacheService.getViewModel(slideModel: slideModel)
		
		XCTAssertNil(slideViewModel, "slideViewModel must be nil")
		
		//Тест кейс 10
		slideViewModel = nil
		fileManager.state = .hasNoData
		slideModel = SlideModel(slideDuration: 0,
								player: nil,
								track: Track(trackName: nil,
											 trackArtist: nil,
											 durationMs: nil,
											 storageDir: yandexUrlString),
								video: nil,
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
		
		slideViewModel = cacheService.getViewModel(slideModel: slideModel)
		
		XCTAssertNil(slideViewModel, "slideViewModel must be nil")
	}
	
	func testGetUrlWithUrlString() {
		var urlString: String!
		var url: URL!
		
		//Test 1
		urlString = ""
		
		url = cacheService.getUrlWith(stringUrl: urlString)
		
		XCTAssertNil(url, "Url must be nil")
		
		//Test 2
		urlString = yandexUrlString
		fileManager.state = .hasData
		
		url = cacheService.getUrlWith(stringUrl: urlString)
		
		XCTAssertNotNil(url, "Url must be not nil")
		
		//Test 3
		urlString = yandexUrlString
		fileManager.state = .hasNoData
		
		url = cacheService.getUrlWith(stringUrl: urlString)
		
		XCTAssertNil(url, "Url must be nil")
	}
	
	func testSaveToCacheIfNeeded() {
		var urlString: String!
		var url: URL!
		
		//Test 1
		urlString = yandexUrlString
		fileManager.state = .hasNoData
		
		url = cacheService.saveToCacheIfNeeded(URL(string: urlString)!, currentLocation: URL(string: urlString)!)
		
		XCTAssertNotNil(url, "Url must be not nil")
		
		//Test 2
		urlString = yandexUrlString
		fileManager.state = .hasData
		
		url = cacheService.saveToCacheIfNeeded(URL(string: urlString)!, currentLocation: URL(string: urlString)!)
		
		XCTAssertNil(url, "Url must be nil")
	}
}

final class FileManagerMock: FileManager {
	enum FileManagerState {
		case hasData
		case hasNoData
	}
	
	var state: FileManagerState = .hasData
	
	override func fileExists(atPath path: String) -> Bool {
		switch state {
		case .hasData:
			return true
		case .hasNoData:
			return false
		}
	}
	
	override func moveItem(at srcURL: URL, to dstURL: URL) throws {
		
	}
}
