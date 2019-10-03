
import XCTest
@testable import StoriesSDK

class ApiClientTest: XCTestCase {

	var apiClient: ApiClientInput!
	
    override func setUp() {
		super.setUp()
		apiClient = ApiClient(cacheService: CacheServiceMock())
    }

    override func tearDown() {
		super.tearDown()
	}

    func testExample() {
		
    }

}

final class CacheServiceMock: CacheServiceInput {
	func getViewModel(slideModel: SlideModel) -> SlideViewModel? {
		
	}
	
	func getUrlWith(stringUrl: String) -> URL? {
		
	}
	
	func saveToCacheIfNeeded(_ url: URL, currentLocation: URL) -> URL? {
		
	}
}
