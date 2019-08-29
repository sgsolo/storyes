
enum SlideViewContentType {
	case video
	case track
	case image
}

struct SlideViewModel {
	var type: SlideViewContentType = .image
	var player: Player?
	var videoUrl: URL?
	var trackUrl: URL?
	var imageUrl: URL?
	
	var isBounded: Bool = false
	var text: String?
	var subtitle: String?
	var header: String?
	var rubric: String?
	
	var track: String?
	var actor: String?
	
	var buttonText: String?
	var buttonType: Int?
	
	mutating func fillFromSlideModel(_ slideModel: SlideModel) {
		self.isBounded = slideModel.isBounded
		self.text = slideModel.text
		self.subtitle = slideModel.subtitle
		self.header = slideModel.header
		self.rubric = slideModel.rubric
		
		self.track = slideModel.trackText
		self.actor = slideModel.actor
		
		self.buttonText = slideModel.buttonText
		self.buttonType = slideModel.buttonType
	}
}
