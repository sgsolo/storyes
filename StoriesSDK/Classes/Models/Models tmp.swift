
struct StoryesJson: Codable {
	let client: String
	let stories: [StoryModel]
}

struct StoryModel: Codable {
	var currentIndex = 0
	let storyId, entityType: String
	let data: DataClass
	
	enum CodingKeys: String, CodingKey {
		case storyId, entityType, data
	}
}

struct DataClass: Codable {
	let service, category: String
	let status: Bool
	let header, image: String
	let dataSlides: [SlideModel]
}

struct SlideModel: Codable {
	let slideDuration: Int?
	var duration: Int {
		if let slideDuration = slideDuration {
			return slideDuration
		}
		return 6
	}
	var player: Player?
	let track: Track?
	let video: Video?
	let image: String?
	let frontImage: String?
	let coverImage: String?
	let buttonURL: String?
	
	var contentStyle: Bool = false
	var description: String?
	var title3: String?
	var title2: String?
	var title: String?
	
	var trackText: String?
	var actor: String?
	
	var buttonText: String?
	var buttonStyle: Int?
	
	var animationType: Int?
	
	enum CodingKeys: String, CodingKey {
		case track, video
		case image, frontImage, coverImage, buttonURL
		case description, title3, title2, title, trackText, actor, buttonText
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
	
	enum CodingKeys: String, CodingKey {
		case trackName, trackArtist
		case durationMs
		case storageDir
	}
}

struct Video: Codable {
	let storageDir: String?
	
	enum CodingKeys: String, CodingKey {
		case storageDir
	}
}

