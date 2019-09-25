
import Foundation

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
