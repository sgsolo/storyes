
import Foundation

struct StoryModel: Codable {
	var currentIndex = 0
	let storyId: String
	let data: StoryData
	
	enum CodingKeys: String, CodingKey {
		case storyId, data
	}
}
