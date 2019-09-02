
import UIKit
import AVFoundation

class KinopoiskSlideView: UIView, SlideViewInput {
	
	let baseLeftRightMargin: CGFloat = 24
	let listenButtonHeight: CGFloat = 48
	
	let backgroundImageView = UIImageView()
	let frontImageView = UIImageView()
	let listenButton = UIButton()
	let ticketsButton = UIButton()
	let bookmarkButton = UIButton()
	let trackLabel = UILabel()
	let textLabel = UILabel()
	let headerLabel = UILabel()
	let rubricLabel = UILabel()
	var playerLayer: AVPlayerLayer?
	var gradientLayer: CAGradientLayer?
	var textLabelBottomConstraint: NSLayoutConstraint?
	var frontImageBottomConstraint: NSLayoutConstraint?
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.addBackgroundImageView()
		self.addListenButton()
		self.addFrontImageView()
		self.addTicketsAndBookmarkButton()
		self.addTrackLabel()
		self.addTextLabel()
		self.addHeaderLabel()
		self.addRubricLabel()
		self.addGradient()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		self.gradientLayer?.frame = self.bounds
		self.playerLayer?.frame = self.bounds
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
			textLabel.isHidden = false
			headerLabel.isHidden = false
			rubricLabel.isHidden = false
			if let frontImageUrl = model.frontImageUrl {
				if let data = try? Data(contentsOf: frontImageUrl) {
					self.frontImageView.image = UIImage(data: data)
					textLabel.isHidden = true
					headerLabel.isHidden = true
					rubricLabel.isHidden = true
				}
			}
		}
		
		textLabel.text = model.text ?? ""
		headerLabel.text = model.header ?? ""
		rubricLabel.text = model.rubric ?? ""
		trackLabel.text = model.track ?? ""
		
		if model.header == nil || model.header == "" {
			textLabel.textColor = .white
		} else {
			textLabel.textColor = UIColor(white: 1, alpha: 0.8)
		}
		
		ticketsButton.isHidden = true
		bookmarkButton.isHidden = true
		if model.buttonType ?? 1 == 5 {
			listenButton.isHidden = true
			ticketsButton.isHidden = false
			bookmarkButton.isHidden = false
			
			textLabelBottomConstraint?.isActive = false
			textLabelBottomConstraint = textLabel.bottomAnchor.constraint(equalTo: self.listenButton.topAnchor, constant: -32)
			textLabelBottomConstraint?.isActive = true
			
			frontImageBottomConstraint?.isActive = false
			frontImageBottomConstraint = frontImageView.bottomAnchor.constraint(equalTo: self.listenButton.topAnchor, constant: -32)
			frontImageBottomConstraint?.isActive = true
		} else if let buttonText = model.buttonText {
			listenButton.isHidden = false
			listenButton.setTitle(buttonText, for: .normal)
			configureButtonWithType(type: model.buttonType ?? 1)
			textLabelBottomConstraint?.isActive = false
			textLabelBottomConstraint = textLabel.bottomAnchor.constraint(equalTo: self.listenButton.topAnchor, constant: -32)
			textLabelBottomConstraint?.isActive = true
			
			frontImageBottomConstraint?.isActive = false
			frontImageBottomConstraint = frontImageView.bottomAnchor.constraint(equalTo: self.listenButton.topAnchor, constant: -32)
			frontImageBottomConstraint?.isActive = true
		} else {
			listenButton.isHidden = true
			textLabelBottomConstraint?.isActive = false
			textLabelBottomConstraint = textLabel.bottomAnchor.constraint(equalTo: self.listenButton.bottomAnchor)
			textLabelBottomConstraint?.isActive = true
			
			frontImageBottomConstraint?.isActive = false
			frontImageBottomConstraint = frontImageView.bottomAnchor.constraint(equalTo: self.listenButton.bottomAnchor)
			frontImageBottomConstraint?.isActive = true
		}
		self.setNeedsLayout()
		self.layoutIfNeeded()
	}
	
	private func addBackgroundImageView() {
		self.addSubview(backgroundImageView)
		backgroundImageView.contentMode = .scaleAspectFill
		backgroundImageView.clipsToBounds = true
		backgroundImageView.layer.cornerRadius = 8
		
		backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
		backgroundImageView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
		backgroundImageView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
		if isIphoneX {
			backgroundImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 54).isActive = true
			backgroundImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -46).isActive = true
		} else {
			backgroundImageView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
			backgroundImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
		}
	}
	
	private func addListenButton() {
		self.addSubview(listenButton)
		listenButton.layer.cornerRadius = 4
		listenButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
		
		listenButton.translatesAutoresizingMaskIntoConstraints = false
		listenButton.heightAnchor.constraint(equalToConstant: listenButtonHeight).isActive = true
		if isIphoneX {
			listenButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -69).isActive = true
		} else {
			listenButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -48).isActive = true
		}
		listenButton.leftAnchor.constraint(equalTo: self.leftAnchor, constant: baseLeftRightMargin).isActive = true
		listenButton.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -baseLeftRightMargin).isActive = true
	}
	
	private func addFrontImageView() {
		self.addSubview(frontImageView)
		frontImageView.contentMode = .scaleAspectFit
		
		frontImageView.translatesAutoresizingMaskIntoConstraints = false
		frontImageBottomConstraint = frontImageView.bottomAnchor.constraint(equalTo: self.listenButton.topAnchor, constant: -32)
		frontImageBottomConstraint?.isActive = true
		frontImageView.heightAnchor.constraint(equalToConstant: 194).isActive = true
		frontImageView.widthAnchor.constraint(equalToConstant: 265).isActive = true
		frontImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
	}
	
	private func addTicketsAndBookmarkButton() {
		self.addSubview(ticketsButton)
		ticketsButton.layer.cornerRadius = 4
		ticketsButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
		ticketsButton.setTitleColor(UIColor(red: 51/255.0, green: 51/255.0, blue: 51/255.0, alpha: 1) , for: .normal)
		ticketsButton.backgroundColor = UIColor(white: 1, alpha: 0.8)
		ticketsButton.setTitle("Расписание и билеты", for: .normal)
		
		ticketsButton.translatesAutoresizingMaskIntoConstraints = false
		ticketsButton.heightAnchor.constraint(equalToConstant: listenButtonHeight).isActive = true
		ticketsButton.leftAnchor.constraint(equalTo: self.leftAnchor, constant: baseLeftRightMargin).isActive = true
		if isIphoneX {
			ticketsButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -69).isActive = true
		} else {
			ticketsButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -48).isActive = true
		}

		bookmarkButton.layer.cornerRadius = 4
		let bundle = Bundle(for: YStoriesManager.self)
		bookmarkButton.setImage(UIImage(named: "bookmarkBlack", in: bundle, compatibleWith: nil), for: .normal)
		bookmarkButton.setTitleColor(UIColor(red: 51/255.0, green: 51/255.0, blue: 51/255.0, alpha: 1) , for: .normal)
		bookmarkButton.backgroundColor = UIColor(white: 1, alpha: 0.8)
		self.addSubview(bookmarkButton)
		
		bookmarkButton.translatesAutoresizingMaskIntoConstraints = false
		bookmarkButton.heightAnchor.constraint(equalToConstant: listenButtonHeight).isActive = true
		bookmarkButton.widthAnchor.constraint(equalToConstant: listenButtonHeight).isActive = true
		bookmarkButton.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -baseLeftRightMargin).isActive = true
		bookmarkButton.leftAnchor.constraint(equalTo: self.ticketsButton.rightAnchor, constant: 8).isActive = true
		bookmarkButton.centerYAnchor.constraint(equalTo: self.ticketsButton.centerYAnchor).isActive = true
	}
	
	private func configureButtonWithType(type: Int) {
		listenButton.titleEdgeInsets = .zero
		listenButton.setImage(nil, for: .normal)
		switch type {
		case 1:
			listenButton.setTitleColor(UIColor(red: 51/255.0, green: 51/255.0, blue: 51/255.0, alpha: 1) , for: .normal)
			listenButton.backgroundColor = UIColor(white: 1, alpha: 0.8)
		case 2:
			listenButton.setTitleColor(UIColor(white: 1, alpha: 0.8) , for: .normal)
			listenButton.backgroundColor = UIColor(white: 1, alpha: 0.08)
		case 3:
			let bundle = Bundle(for: YStoriesManager.self)
			listenButton.setImage(UIImage(named: "bookmarkWhite", in: bundle, compatibleWith: nil), for: .normal)
			listenButton.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0)
			listenButton.setTitleColor(.white, for: .normal)
			listenButton.backgroundColor = UIColor(red: 1, green: 102/255.0, blue: 0, alpha: 1)
		case 4:
			let bundle = Bundle(for: YStoriesManager.self)
			listenButton.setImage(UIImage(named: "bookmarkBlack", in: bundle, compatibleWith: nil), for: .normal)
			listenButton.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0)
			listenButton.setTitleColor(UIColor(red: 51/255.0, green: 51/255.0, blue: 51/255.0, alpha: 1) , for: .normal)
			listenButton.backgroundColor = UIColor(white: 1, alpha: 0.8)
		default:
			listenButton.setTitleColor(UIColor(red: 51/255.0, green: 51/255.0, blue: 51/255.0, alpha: 1) , for: .normal)
			listenButton.backgroundColor = UIColor(white: 1, alpha: 0.1)
		}
	}
	
	private func addTextLabel() {
		self.addSubview(textLabel)
		textLabel.numberOfLines = 0
		textLabel.font = UIFont.systemFont(ofSize: 20, weight: .medium)
		textLabel.textColor = UIColor(white: 1, alpha: 0.8)
		
		textLabel.translatesAutoresizingMaskIntoConstraints = false
		textLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: baseLeftRightMargin).isActive = true
		textLabelBottomConstraint = textLabel.bottomAnchor.constraint(equalTo: self.listenButton.topAnchor, constant: -32)
		textLabelBottomConstraint?.isActive = true
		textLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -baseLeftRightMargin).isActive = true
	}
	
	private func addHeaderLabel() {
		self.addSubview(headerLabel)
		headerLabel.numberOfLines = 0
		headerLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
		headerLabel.textColor = .white
		
		headerLabel.translatesAutoresizingMaskIntoConstraints = false
		headerLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: baseLeftRightMargin).isActive = true
		headerLabel.bottomAnchor.constraint(equalTo: self.textLabel.topAnchor, constant: -10).isActive = true
		headerLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -baseLeftRightMargin).isActive = true
	}
	
	private func addRubricLabel() {
		self.addSubview(rubricLabel)
		rubricLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
		rubricLabel.textColor = UIColor(red: 1, green: 102/255.0, blue: 0, alpha: 1)
		
		rubricLabel.translatesAutoresizingMaskIntoConstraints = false
		rubricLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: baseLeftRightMargin).isActive = true
		rubricLabel.bottomAnchor.constraint(equalTo: self.headerLabel.topAnchor, constant: -8).isActive = true
		rubricLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -baseLeftRightMargin).isActive = true
	}
	
	private func addTrackLabel() {
		self.addSubview(trackLabel)
		trackLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
		trackLabel.textColor = UIColor(white: 1, alpha: 0.8)
		
		
		trackLabel.translatesAutoresizingMaskIntoConstraints = false
		trackLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: baseLeftRightMargin).isActive = true
		trackLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -60).isActive = true
		if isIphoneX {
			trackLabel.topAnchor.constraint(equalTo: self.backgroundImageView.topAnchor, constant: 39).isActive = true
		} else {
			trackLabel.topAnchor.constraint(equalTo: self.backgroundImageView.topAnchor, constant: 57).isActive = true
		}
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
			UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).cgColor,
			UIColor(red: 0, green: 0, blue: 0, alpha: 1).cgColor
		]
		
		self.backgroundImageView.layer.insertSublayer(gradientLayer, at: 0)
		self.gradientLayer = gradientLayer
	}
}

var isIphoneX: Bool {
	if #available(iOS 11.0, *) {
		return UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0 > 0
	}
	return false
}
