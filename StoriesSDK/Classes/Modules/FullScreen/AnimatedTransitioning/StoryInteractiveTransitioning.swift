import UIKit

class StoryInteractiveTransitioning: NSObject, UIViewControllerInteractiveTransitioning {
	
	var transitionContext: UIViewControllerContextTransitioning?
	var animator: StoryAnimatedTransitioning
	var percentComplete: CGFloat = 0
	
	init(animator: StoryAnimatedTransitioning) {
		self.animator = animator
		super.init()
	}
	
	func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
		self.transitionContext = transitionContext
		animator.setStartPosition(using: transitionContext)
	}
	
	func duration() -> TimeInterval {
		return animator.transitionDuration(using: transitionContext)
	}
	
	func updateInteractiveTransition(percentComplete: CGFloat) {
		guard let transitionContext = transitionContext else { return }
		self.percentComplete = percentComplete
		animator.updatePosition(using: transitionContext, percentComplete: percentComplete)
	}
	
	func cancelInteractiveTransition() {
		guard let transitionContext = transitionContext else { return }
		transitionContext.cancelInteractiveTransition()
		animator.animateTransition(using: transitionContext)
	}
	
	func finishInteractiveTransition() {
		guard let transitionContext = transitionContext else { return }
		animator.animateTransition(using: transitionContext)
	}
}
