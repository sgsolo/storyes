import UIKit

enum AnimationMode {
	case scaleAspectFill
	case scale
	case left
	case right
}

final class AnimatedImageView: UIView {
	
	var image: UIImage? {
		get { return imageView.image }
		set {
			imageView.image = newValue
			layoutImageView()
		}
	}
	private let imageView = UIImageView()
	
	init() {
		self.animationMode = .scaleAspectFill
		super.init(frame: .zero)
		addSubview(imageView)
	}
	
	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		layoutImageView()
	}
	
	var animationMode: AnimationMode {
		didSet { layoutImageView() }
	}
	
	private func layoutImageView() {
		guard let image = imageView.image else { return }
		
		func layoutAspectFill() {
			let widthRatio = imageToBoundsWidthRatio(image: image)
			let heightRatio = imageToBoundsHeightRatio(image: image)
			imageViewBoundsToSize(size: CGSize(width: image.size.width /  min(widthRatio, heightRatio), height: image.size.height / min(widthRatio, heightRatio)))
			centerImageView()
		}
		
		func layoutScale() {
			let widthRatio = imageToBoundsWidthRatio(image: image)
			let heightRatio = imageToBoundsHeightRatio(image: image)
			let scaleFactor: CGFloat = 1.1
			imageViewBoundsToSize(size: CGSize(width: image.size.width * scaleFactor /  min(widthRatio, heightRatio), height: image.size.height * scaleFactor / min(widthRatio, heightRatio)))
			centerImageView()
		}
		
		func layoutLeft() {
			let widthRatio = imageToBoundsWidthRatio(image: image)
			let heightRatio = imageToBoundsHeightRatio(image: image)
			imageViewBoundsToSize(size: CGSize(width: image.size.width / min(widthRatio, heightRatio), height: image.size.height / min(widthRatio, heightRatio)))
		}
		
		func layoutRight() {
			centerImageViewToPoint(point: CGPoint(x: bounds.width - imageView.frame.width / 2, y: imageView.frame.height / 2))
		}
		
		switch animationMode {
		case .scaleAspectFill: layoutAspectFill()
		case .scale: layoutScale()
		case .left: layoutLeft()
		case .right: layoutRight()
		}
	}
	
	private func imageToBoundsWidthRatio(image: UIImage) -> CGFloat {
		return image.size.width / bounds.size.width
	}
	
	private func imageToBoundsHeightRatio(image: UIImage) -> CGFloat {
		return image.size.height / bounds.size.height
	}
	
	private func centerImageViewToPoint(point: CGPoint) {
		imageView.center = point
	}
	
	private func imageViewBoundsToSize(size: CGSize) {
		imageView.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
	}
	
	private func centerImageView() {
		imageView.center = CGPoint(x: bounds.size.width / 2, y: bounds.size.height / 2)
	}
}
