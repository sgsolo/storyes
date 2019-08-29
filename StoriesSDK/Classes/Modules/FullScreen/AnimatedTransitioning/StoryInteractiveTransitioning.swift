import UIKit

class StoryInteractiveTransitioning: NSObject, UIViewControllerInteractiveTransitioning {
	
	var transitionContext: UIViewControllerContextTransitioning?
	var animator: UIViewControllerAnimatedTransitioning
	var displayLink: CADisplayLink?
	var percentComplete: CGFloat = 0 {
		didSet {
			self.setTimeOffset(timeOffset: Double(percentComplete) * duration())
			transitionContext?.updateInteractiveTransition(percentComplete)
		}
	}
	
	init(animator: UIViewControllerAnimatedTransitioning) {
		self.animator = animator
		super.init()
	}
	
	func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
		self.transitionContext = transitionContext
		self.transitionContext?.containerView.layer.speed = 0
		animator.animateTransition(using: transitionContext)
	}
	
	func duration() -> TimeInterval {
		return animator.transitionDuration(using: transitionContext)
	}
	
	func updateInteractiveTransition(percentComplete: CGFloat) {
		self.percentComplete = max(min(percentComplete, 1), 0)
	}
	
	func cancelInteractiveTransition() {
		displayLink = CADisplayLink(target: self, selector: #selector(tickCancelAnimation))
		displayLink?.add(to: .main, forMode: .commonModes)
		transitionContext?.cancelInteractiveTransition()
	}
	
	func finishInteractiveTransition() {
		guard let layer = transitionContext?.containerView.layer else { return }
		layer.speed = 1;
		let pausedTime = layer.timeOffset
		layer.timeOffset = 0.0
		layer.beginTime = 0.0
		let timeSincePause = layer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
		layer.beginTime = timeSincePause
		transitionContext?.finishInteractiveTransition()
	}
	
	func setTimeOffset(timeOffset: TimeInterval) {
		transitionContext?.containerView.layer.timeOffset = timeOffset
	}
	@objc func tickCancelAnimation() {
		guard let displayLink = displayLink else { return }
		let timeOffset = self.timeOffset() - displayLink.duration;
		if timeOffset < 0 {
			self.transitionFinishedCanceling()
		} else {
			self.setTimeOffset(timeOffset: timeOffset)
		}
	}
	func timeOffset() -> CFTimeInterval {
		return transitionContext?.containerView.layer.timeOffset ?? 0
	}
	func transitionFinishedCanceling() {
		displayLink?.invalidate()
		
		guard let layer = transitionContext?.containerView.layer else { return }
		layer.speed = 1;
	}
}
