
import UIKit
import AVFoundation

class SlideView: UIView, SlideViewInputTrait {
	lazy var backgroundImageView: AnimatedImageView = {
		return buildAnimatedImageView()
	}()
	
	weak var delegate: SlideViewOutput?
	var slideViewModel: SlideViewModel?
	var playerLayer: AVPlayerLayer?
	var contentCornerRadius: CGFloat {
		return 0
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		playerLayer?.frame = self.backgroundImageView.bounds
		playerLayer?.position = self.backgroundImageView.center
	}
	
	func setSlide(model: SlideViewModel) { }
	
	func performContentAnimation(model: SlideViewModel, needAnimation: Bool, propertyAnimator: UIViewPropertyAnimator?) { }
	
	func addPlayerLayer(player: AVPlayer) {
		playerLayer?.isHidden = false
		if playerLayer == nil {
			let layer = AVPlayerLayer(player: player)
			layer.masksToBounds = true
			layer.cornerRadius = contentCornerRadius
			layer.videoGravity = .resizeAspectFill
			playerLayer = layer
			self.layer.insertSublayer(layer, at: 0)
		} else {
			playerLayer?.player = player
		}
		playerLayer?.frame = self.backgroundImageView.bounds
		playerLayer?.position = self.backgroundImageView.center
	}
	
	private func buildAnimatedImageView() -> AnimatedImageView {
		let imageView = AnimatedImageView()
		imageView.clipsToBounds = true
		imageView.layer.cornerRadius = contentCornerRadius
		imageView.translatesAutoresizingMaskIntoConstraints = false
		return imageView
	}
}
