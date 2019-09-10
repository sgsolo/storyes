
// MARK: - Welcome
public struct StoryesJson: Codable {
	let result: Result
}

// MARK: - Result
public struct Result: Codable {
	let client: String
	let blocks: Blocks
}

// MARK: - Blocks
public struct Blocks: Codable {
	let id, type, typeForFrom, title: String
	let uid: String
	let entities: [StoryModel]
}

// MARK: - Entity
public struct StoryModel: Codable {
	var currentIndex = 0
	let storyid, type: String
	let data: DataClass
	let dataSlides: [SlideModel]
	
	enum CodingKeys: String, CodingKey {
		case storyid, type, data
		case dataSlides
	}
}

// MARK: - DataClass
public struct DataClass: Codable {
	let service, category: String
	let promo: Bool
	let position, status: Int
	let header, image: String
}

// MARK: - DataSlide
public struct SlideModel: Codable {
	let duration = 6
	var player: Player?
	let track: Track?
	let video: Video?
	let image: String?
	let frontImage: String?
	let title, title2, description: String
	let coverImage: String?
	let buttonURL: Int
	let buttonColor, buttonTextColor: String
	
	var isBounded: Bool = false
	var text: String?
	var subtitle: String?
	var header: String?
	var rubric: String?
	
	var trackText: String?
	var actor: String?
	
	var buttonText: String?
	var buttonType: Int?
	
	var animationType: Int?
	
	enum CodingKeys: String, CodingKey {
		case track, title, title2, video
		case description
		case image, frontImage, coverImage, buttonURL, buttonColor, buttonTextColor
		case text, subtitle, header, rubric, trackText, actor, buttonText
		case buttonType
		case animationType
		case isBounded
	}
}

// MARK: - Track
public struct Track: Codable {
	let id, title: String
	let durationMs: Int
	let storageDir, ogImage: String
	let fileSize: Int
	let trackUrl: String?
	let artists: [Artist]
	
	enum CodingKeys: String, CodingKey {
		case id, title, trackUrl
		case durationMs
		case storageDir, ogImage, fileSize, artists
	}
}

public struct Video: Codable {
	let id, title: String
	let durationMs: Int
	let storageDir, ogImage: String
	let fileSize: Int
	let videoUrl: String?
	let artists: [Artist]
	
	enum CodingKeys: String, CodingKey {
		case id, title, videoUrl
		case durationMs
		case storageDir, ogImage, fileSize, artists
	}
}

// MARK: - Artist
public struct Artist: Codable {
	let id: Int
	let name: String
}
