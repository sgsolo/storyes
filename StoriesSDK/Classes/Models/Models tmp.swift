
struct StoryesModel: Codable {
	let client: String
	let stories: [StoryModel]
}

struct StoryModel: Codable {
	var currentIndex = 0
	let storyId: String
	let entityType: String
	let data: StoryData
	
	enum CodingKeys: String, CodingKey {
		case storyId, entityType, data
	}
}

struct StoryData: Codable {
	let service: String
	let category: String
	let status: Bool
	let header: String
	let image: String
	let dataSlides: [SlideModel]
}

struct SlideModel: Codable {
	let slideDuration: Int?
	var duration: Int {
		guard let slideDuration = slideDuration else { return 6 }
		return slideDuration
	}
	var player: Player?
	let track: Track?
	let video: Video?
	let image: String?
	let frontImage: String?
	let buttonURL: String?
	
	var contentStyle: Bool = false
	var description: String?
	var title3: String?
	var title2: String?
	var title: String
	
	var buttonText: String?
	var buttonStyle: Int?
	
	var animationType: Int?
	
	enum CodingKeys: String, CodingKey {
		case track, video
		case image, frontImage, buttonURL
		case description, title3, title2, title, buttonText
		case buttonStyle
		case animationType, slideDuration
		case contentStyle
	}
}

struct Track: Codable {
	let trackName: String?
	let trackArtist: String?
	let durationMs: Int?
	let storageDir: String?
}

struct Video: Codable {
	let storageDir: String?
}

