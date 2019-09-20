
import UIKit
import AVFoundation

class MusicSlideView: UIView, SlideViewInput {
	
	private let leftRightButtonMargin: CGFloat = 68
	private let baseLeftRightMargin: CGFloat = 16
	private let listenButtonHeight: CGFloat = 40
	
	private let backgroundImageView = AnimatedImageView()
	private let backgroundImageViewTopGradientContainer = UIView()
	private let listenButton = UIButton()
	private let trackLabel = UILabel()
	private let actorLabel = UILabel()
	private let textLabel = UILabel()
	private let subtitleLabel = UILabel()
	private let headerLabel = UILabel()
	private let rubricLabel = UILabel()
	private var playerLayer: AVPlayerLayer?
	private var gradientLayer: CAGradientLayer?
	private var topGradientLayer: CAGradientLayer?
	private var bottomButtonConstraint: NSLayoutConstraint?
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.addBackgroundImageView()
		self.addBackgroundImageViewTopGradient()
		self.addTopGradient()
		self.addListenButton()
		self.addTrackLabel()
		self.addActorLabel()
		self.addTextLabel()
		self.addSubtitleLabel()
		self.addHeaderLabel()
		self.addRubricLabel()
		self.addGradient()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
		if listenButton.frame.contains(point), !listenButton.isHidden {
			return listenButton
		}
		return nil
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		self.gradientLayer?.bounds = self.bounds.insetBy(dx: -0.5 * self.bounds.size.width, dy: -0.5 * self.bounds.size.height)
		self.gradientLayer?.position = self.center
		
		self.topGradientLayer?.frame = backgroundImageViewTopGradientContainer.bounds
		playerLayer?.frame = self.bounds
	}
	
	func setSlide(model: SlideViewModel) {
		self.backgroundImageView.image = nil
		switch model.type {
		case .video:
			if let avPlayer = model.player?.avPlayer {
				addPlayerLayer(player: avPlayer)
			}
		case .track:
			fallthrough
		case .image:
			playerLayer?.isHidden = true
			if let imageUrl = model.imageUrl {
				if let data = try? Data(contentsOf: imageUrl) {
					self.backgroundImageView.image = UIImage(data: data)
				}
			}
		}
		
		let isBounded = model.isBounded
		textLabel.attributedText = attributedTextForTextLabel(text: model.text ?? "", isBounded: isBounded)
		subtitleLabel.attributedText = attributedTextForSubtitleLabel(text: model.subtitle ?? "", isBounded: isBounded)
		headerLabel.attributedText = attributedTextForHeaderLabel(text: model.header ?? "", isBounded: isBounded)
		rubricLabel.attributedText = attributedTextForRubricLabel(text: model.rubric ?? "", isBounded: isBounded)

		trackLabel.text = model.track ?? ""
		actorLabel.text = model.actor ?? ""

		if let buttonText = model.buttonText {
			listenButton.isHidden = false
			listenButton.setTitle(buttonText, for: .normal)
			configureButtonWithType(type: model.buttonStyle ?? 1)
		} else {
			listenButton.isHidden = true
		}
		self.setNeedsLayout()
		self.layoutIfNeeded()
	}
	
	func performContentAnimation(model: SlideViewModel, needAnimation: Bool, propertyAnimator: UIViewPropertyAnimator?) {
		switch model.animationType {
		case .contentFadeIn:
			self.setAlphaForAnimatedViews(alpha: 0)
			bottomButtonConstraint?.constant = 50
			self.layoutIfNeeded()
			bottomButtonConstraint?.constant = -48
			if needAnimation {
				propertyAnimator?.addAnimations {
					self.layoutIfNeeded()
					self.setAlphaForAnimatedViews(alpha: 1)
				}
			}
		case .backgroundAnimationLeftToRight:
			backgroundImageView.animationMode = .left
			if needAnimation {
				propertyAnimator?.addAnimations {
					self.backgroundImageView.animationMode = .right
				}
			}
		case .backgroundAnimationZoomIn:
			backgroundImageView.animationMode = .scaleAspectFill
			if needAnimation {
				propertyAnimator?.addAnimations {
					self.backgroundImageView.animationMode = .scale
				}
			}
		default:
			break
		}
	}
	
	private func setAlphaForAnimatedViews(alpha: CGFloat) {
		self.listenButton.alpha = alpha
		self.rubricLabel.alpha = alpha
		self.headerLabel.alpha = alpha
		self.subtitleLabel.alpha = alpha
		self.textLabel.alpha = alpha
	}
	
	private func addBackgroundImageView() {
		self.addSubview(backgroundImageView)
		backgroundImageView.clipsToBounds = true
		backgroundImageView.layer.cornerRadius = 12
		
		backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
		backgroundImageView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
		backgroundImageView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
		backgroundImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 44).isActive = true
		backgroundImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -102).isActive = true
	}
	
	private func addBackgroundImageViewTopGradient() {
		self.backgroundImageView.addSubview(backgroundImageViewTopGradientContainer)
		backgroundImageViewTopGradientContainer.alpha = 0.4
		backgroundImageViewTopGradientContainer.translatesAutoresizingMaskIntoConstraints = false
		backgroundImageViewTopGradientContainer.leftAnchor.constraint(equalTo: self.backgroundImageView.leftAnchor).isActive = true
		backgroundImageViewTopGradientContainer.rightAnchor.constraint(equalTo: self.backgroundImageView.rightAnchor).isActive = true
		backgroundImageViewTopGradientContainer.topAnchor.constraint(equalTo: self.backgroundImageView.topAnchor).isActive = true
		backgroundImageViewTopGradientContainer.heightAnchor.constraint(equalToConstant: 100).isActive = true
	}
	
	private func addTopGradient() {
		let gradientLayer = CAGradientLayer()
		gradientLayer.colors = [
			UIColor(red: 0.06, green: 0.06, blue: 0.06, alpha: 1).cgColor,
			UIColor(red: 0, green: 0, blue: 0, alpha: 0).cgColor
		]
		gradientLayer.locations = [0, 1]
		gradientLayer.startPoint = CGPoint(x: 0.25, y: 0.5)
		gradientLayer.endPoint = CGPoint(x: 0.75, y: 0.5)
		gradientLayer.transform = CATransform3DMakeAffineTransform(CGAffineTransform(a: 0, b: 1, c: -1, d: 0, tx: 1, ty: 0))
		
		self.backgroundImageViewTopGradientContainer.layer.insertSublayer(gradientLayer, at: 0)
		self.topGradientLayer = gradientLayer
	}
	
	private func addListenButton() {
		self.addSubview(listenButton)
		listenButton.layer.cornerRadius = listenButtonHeight / 2
		listenButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
		
		listenButton.translatesAutoresizingMaskIntoConstraints = false
		listenButton.heightAnchor.constraint(equalToConstant: listenButtonHeight).isActive = true
		listenButton.widthAnchor.constraint(equalToConstant: 240).isActive = true
		listenButton.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
		bottomButtonConstraint = listenButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -48)
		bottomButtonConstraint?.isActive = true
		
		listenButton.backgroundColor = .white
	}
	
	private func configureButtonWithType(type: Int) {
		switch type {
		case 1:
			listenButton.setTitleColor(.white , for: .normal)
			listenButton.backgroundColor = UIColor(white: 1, alpha: 0.1)
		case 2:
			listenButton.setTitleColor(.black , for: .normal)
			listenButton.backgroundColor = .white
		case 3:
			listenButton.setTitleColor(.black , for: .normal)
			listenButton.backgroundColor = UIColor(red: 1, green: 0.87, blue: 0.38, alpha: 1)
		default:
			listenButton.setTitleColor(.white , for: .normal)
			listenButton.backgroundColor = UIColor(white: 1, alpha: 0.1)
		}
	}
	
	private func addTextLabel() {
		self.addSubview(textLabel)
		textLabel.numberOfLines = 0
		
		textLabel.translatesAutoresizingMaskIntoConstraints = false
		textLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: baseLeftRightMargin).isActive = true
		textLabel.bottomAnchor.constraint(equalTo: self.listenButton.topAnchor, constant: -36).isActive = true
		textLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -baseLeftRightMargin).isActive = true
	}
	
	private func attributedTextForTextLabel(text: String, isBounded: Bool) -> NSAttributedString {
		if isBounded {
			return self.attributedText(text: text, foregroundColor: .black, backgroundColor: .white, font: .systemFont(ofSize: 24, weight: .medium))
		} else {
			return self.attributedText(text: text, foregroundColor: .white, backgroundColor: .clear, font: .systemFont(ofSize: 24, weight: .medium))
		}
	}
	
	private func addSubtitleLabel() {
		self.addSubview(subtitleLabel)
		subtitleLabel.numberOfLines = 0
		
		subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
		subtitleLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: baseLeftRightMargin).isActive = true
		subtitleLabel.bottomAnchor.constraint(equalTo: self.textLabel.topAnchor, constant: -8).isActive = true
		subtitleLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -baseLeftRightMargin).isActive = true
	}
	
	private func attributedTextForSubtitleLabel(text: String, isBounded: Bool) -> NSAttributedString {
		if isBounded {
			return self.attributedText(text: text,
									   foregroundColor: UIColor(red: 0.71, green: 0.54, blue: 0.21, alpha: 1),
									   backgroundColor: .white,
									   font: .systemFont(ofSize: 36, weight: .bold))
		} else {
			return self.attributedText(text: text,
									   foregroundColor: UIColor(red: 1, green: 0.89, blue: 0.67, alpha: 1),
									   backgroundColor: .clear,
									   font: .systemFont(ofSize: 36, weight: .bold))
		}
	}
	
	private func addHeaderLabel() {
		self.addSubview(headerLabel)
		headerLabel.numberOfLines = 0
		
		headerLabel.translatesAutoresizingMaskIntoConstraints = false
		headerLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: baseLeftRightMargin).isActive = true
		headerLabel.bottomAnchor.constraint(equalTo: self.subtitleLabel.topAnchor, constant: 0).isActive = true
		headerLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -baseLeftRightMargin).isActive = true
	}
	
	private func attributedTextForHeaderLabel(text: String, isBounded: Bool) -> NSAttributedString {
		if isBounded {
			return self.attributedText(text: text,
									   foregroundColor: .black,
									   backgroundColor: .white,
									   font: .systemFont(ofSize: 36, weight: .bold))
		} else {
			return self.attributedText(text: text,
									   foregroundColor: .white,
									   backgroundColor: .clear,
									   font: .systemFont(ofSize: 36, weight: .bold))
		}
	}
	
	private func addRubricLabel() {
		self.addSubview(rubricLabel)
		
		rubricLabel.translatesAutoresizingMaskIntoConstraints = false
		rubricLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: baseLeftRightMargin).isActive = true
		rubricLabel.bottomAnchor.constraint(equalTo: self.headerLabel.topAnchor, constant: -8).isActive = true
		rubricLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -baseLeftRightMargin).isActive = true
	}
	
	private func attributedTextForRubricLabel(text: String, isBounded: Bool) -> NSAttributedString {
		if isBounded {
			return self.attributedText(text: text,
									   foregroundColor: .black,
									   backgroundColor: .white,
									   font: .systemFont(ofSize: 12, weight: .medium))
		} else {
			return self.attributedText(text: text,
									   foregroundColor: .white,
									   backgroundColor: .clear,
									   font: .systemFont(ofSize: 12, weight: .medium))
		}
	}
	
	private func addTrackLabel() {
		self.addSubview(trackLabel)
		trackLabel.font = .systemFont(ofSize: 16, weight: .medium)
		trackLabel.textColor = .white
		
		
		trackLabel.translatesAutoresizingMaskIntoConstraints = false
		trackLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: baseLeftRightMargin).isActive = true
		trackLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 80).isActive = true
		trackLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -60).isActive = true
	}
	
	private func addActorLabel() {
		self.addSubview(actorLabel)
		actorLabel.alpha = 0.5
		actorLabel.font = .systemFont(ofSize: 16, weight: .medium)
		actorLabel.textColor = .white
		
		actorLabel.translatesAutoresizingMaskIntoConstraints = false
		actorLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: baseLeftRightMargin).isActive = true
		actorLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 101).isActive = true
		actorLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -60).isActive = true
	}
	
	private func addPlayerLayer(player: AVPlayer) {
		playerLayer?.isHidden = false
		if playerLayer == nil {
			let layer = AVPlayerLayer(player: player)
			playerLayer = layer
			self.layer.insertSublayer(layer, at: 0)
		} else {
			playerLayer?.player = player
		}
		playerLayer?.frame = self.bounds
	}
	
	private func addGradient() {
		let gradientLayer = CAGradientLayer()
		gradientLayer.colors = [
			UIColor(red: 0, green: 0, blue: 0, alpha: 0).cgColor,
			UIColor(red: 0.06, green: 0.06, blue: 0.06, alpha: 1).cgColor
		]
		gradientLayer.locations = [0, 1]
		gradientLayer.startPoint = CGPoint(x: 0.25, y: 0.5)
		gradientLayer.endPoint = CGPoint(x: 0.75, y: 0.5)
		gradientLayer.transform = CATransform3DMakeAffineTransform(CGAffineTransform(a: 0, b: 1, c: -1, d: 0, tx: 1, ty: 0))

		self.backgroundImageView.layer.addSublayer(gradientLayer)
		self.gradientLayer = gradientLayer
	}
	
	private func attributedText(text: String, foregroundColor: UIColor, backgroundColor: UIColor, font: UIFont) -> NSMutableAttributedString {
		let attributes: [NSAttributedStringKey: Any] = [
			.foregroundColor: foregroundColor,
			.backgroundColor: backgroundColor,
			.font: font
		]
		
		return NSMutableAttributedString(string: text, attributes: attributes)
	}
}
