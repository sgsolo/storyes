import Foundation

protocol StoryCellDelegate: class {
	func storyCellDidTapOnLeftSide()
	func storyCellDidTapOnRightSide()
	func storyCellTouchesBegan()
	func storyCellTouchesCancelled()
	func storyCellDidTouchesEnded()
	
	func closeButtonDidTap()
}

class StoryCell: UICollectionViewCell {
	
	weak var delegate: StoryCellDelegate?
	var slideView = UIImageView()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		addSlideView()
		addGestureRecognizers()
		addCloseButton()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func addSlideView() {
		self.addSubview(slideView)
		slideView.contentMode = .center
		slideView.translatesAutoresizingMaskIntoConstraints = false
		slideView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
		slideView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
		slideView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
		slideView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
	}
	
	private func addGestureRecognizers() {
		let leftTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapOnLeftSide))
		let leftTapArea = UIView(frame: .zero)
		leftTapArea.translatesAutoresizingMaskIntoConstraints = false
		leftTapArea.addGestureRecognizer(leftTapGestureRecognizer)
		self.addSubview(leftTapArea)
		
		let rightTapArea = UIView(frame: .zero)
		rightTapArea.translatesAutoresizingMaskIntoConstraints = false
		let rightTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapOnRightSide))
		rightTapArea.addGestureRecognizer(rightTapGestureRecognizer)
		self.addSubview(rightTapArea)
		
		leftTapArea.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
		leftTapArea.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
		leftTapArea.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
		leftTapArea.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.5).isActive = true
		
		rightTapArea.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
		rightTapArea.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
		rightTapArea.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
		rightTapArea.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.5).isActive = true
	}
	
	private func addCloseButton() {
		let button = UIButton(type: .custom)
		let bundle = Bundle(for: StoryCell.self)
		button.setImage(UIImage(named: "closeIcon", in: bundle, compatibleWith: nil), for: .normal)
		button.frame = CGRect(x: UIScreen.main.bounds.width - 50, y: 50, width: 50, height: 50)
		button.addTarget(self, action: #selector(closeButtonDidTap), for: .touchUpInside)
		self.addSubview(button)
	}
}

// MARK: - Actions
extension StoryCell {
	@objc private func tapOnLeftSide() {
		print("tapOnLeftSide")
		delegate?.storyCellDidTapOnLeftSide()
	}
	
	@objc private func tapOnRightSide() {
		print("tapOnRightSide")
		delegate?.storyCellDidTapOnRightSide()
	}
	
	@objc private func closeButtonDidTap() {
		print("closeButtonDidTap")
		delegate?.closeButtonDidTap()
	}
}

// MARK: - UIResponder
extension StoryCell {
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesBegan(touches, with: event)
		print("touchesBegan")
		delegate?.storyCellTouchesBegan()
	}
	
	override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesCancelled(touches, with: event)
		print("touchesCancelled")
		delegate?.storyCellTouchesCancelled()
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesEnded(touches, with: event)
		print("touchesEnded")
		delegate?.storyCellDidTouchesEnded()
	}
}

extension StoryCell: RegistrableComponent {}

extension StoryCell: CollectionViewItemsSizeProvider {
	static func size(for item: Any?, collectionViewSize: CGSize) -> CGSize {
		return CGSize(width: collectionViewSize.width, height: collectionViewSize.height)
	}
}

extension StoryCell: ConfigurableComponent {
	func configure(with object: Any) {
		print("configure")
		if let slideModels = object as? [SlideModel],
			let slideModel = slideModels.first {
			self.slideView.backgroundColor = slideModel.color
			self.slideView.image = slideModel.image
		}
	}
}
