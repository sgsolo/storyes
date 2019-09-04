
import UIKit

class LoaderView: UIView {
	private lazy var circleLayer: CAShapeLayer = {
		return createCircleLayer()
	}()
	
	private var rotationAnimation: CABasicAnimation?
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.backgroundColor = .black
		self.startAnimation()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func createCircleLayer() -> CAShapeLayer {
		let radius: CGFloat = 39.0
		let circleLayer = CAShapeLayer()
		circleLayer.path = UIBezierPath(arcCenter: circleLayer.position, radius: radius / 2, startAngle: 0, endAngle: CGFloat(3 * Float.pi / 2) , clockwise: true).cgPath
		circleLayer.strokeColor = UIColor.white.cgColor
		circleLayer.lineWidth = 3
		circleLayer.lineCap = "round"
		self.layer.addSublayer(circleLayer)
		return circleLayer
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		circleLayer.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
	}
	
	private func startAnimation() {
		guard self.rotationAnimation == nil else { return }
		let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
		rotationAnimation.fromValue = 0.0
		rotationAnimation.toValue = Float.pi * 2
		rotationAnimation.duration = 1
		rotationAnimation.isRemovedOnCompletion = false
		rotationAnimation.repeatCount = .greatestFiniteMagnitude
		circleLayer.add(rotationAnimation, forKey: nil)
		self.rotationAnimation = rotationAnimation
	}
}
