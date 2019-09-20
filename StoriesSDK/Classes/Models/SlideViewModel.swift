
import Foundation

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
	
	private var _buttonText: String?
	var buttonText: String? {
		get {
			return _buttonText
		}
		set {
			guard let newValue = newValue, !newValue.isEmpty else { return }
			_buttonText = newValue
		}
	}
	var buttonStyle: Int?
	var buttonURL: URL?
	
	var slideDuration: Int = 0
	var animationDuration: Float {
		switch animationType {
		case .none:
			return 0
		case .contentFadeIn:
			return 0.25
		case .backgroundAnimationLeftToRight:
			return Float(slideDuration)
		case .backgroundAnimationZoomIn:
			return Float(slideDuration)
		}
	}
	var animationType = AnimationType.none
	
	mutating func fillFromSlideModel(_ slideModel: SlideModel) {
		self.isBounded = slideModel.contentStyle
		self.text = slideModel.description
		self.subtitle = slideModel.title3
		self.header = slideModel.title2
		self.rubric = slideModel.title
		
		self.track = slideModel.track?.trackName
		self.actor = slideModel.track?.trackArtist
		
		self.buttonText = slideModel.buttonText
		self.buttonStyle = slideModel.buttonStyle
		if let buttonURL = slideModel.buttonURL {
			self.buttonURL = URL(string: buttonURL)
		}
		
		self.slideDuration = slideModel.duration
		
		if let animationType = slideModel.animationType, let animation = AnimationType(rawValue: animationType) {
			self.animationType = animation
		}
	}
}
