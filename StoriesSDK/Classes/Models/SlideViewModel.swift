
enum SlideViewContentType {
	case video
	case track
	case image
}

enum AnimationType: Int {
	case none
	case contentFadeIn
	case backgroundAnimationLeftToRight
	case backgroundAnimationZoomIn
}

struct SlideViewModel {
	var type: SlideViewContentType = .image
	var player: Player?
	var videoUrl: URL?
	var trackUrl: URL?
	var imageUrl: URL?
	var frontImageUrl: URL?
	
	var isBounded: Bool = false
	var text: String?
	var subtitle: String?
	var header: String?
	var rubric: String?
	
	var track: String?
	var actor: String?
	
	var buttonText: String?
	var buttonType: Int?
	
	var slideDuration: Int = 0
	var animationDuration: Int {
		switch animationType {
		case .none:
			return 0
		case .contentFadeIn:
			return 1
		case .backgroundAnimationLeftToRight:
			return slideDuration
		case .backgroundAnimationZoomIn:
			return slideDuration
		}
	}
	var animationType = AnimationType.none
	
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
		
		self.slideDuration = slideModel.duration
		
		if let animationType = slideModel.animationType, let animation = AnimationType(rawValue: animationType) {
			self.animationType = animation
		}
	}
}
