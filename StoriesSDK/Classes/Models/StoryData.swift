
import Foundation

struct StoryData: Codable {
	let service: String
	let category: String
	let status: Bool
	let header: String
	let image: String
	let dataSlides: [SlideModel]
}
