import UIKit

enum Direction {
	case leftToRight
	case rightToLeft
}

class StoryAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
	
	let direction: Direction
	
	init(direction: Direction) {
		self.direction = direction
		
		super.init()
	}
	
	func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
		let inView   = transitionContext.containerView
		guard let toView   = transitionContext.view(forKey: .to),
			let fromView = transitionContext.view(forKey: .from) else { return }
		
		let frame = inView.bounds
		let padding: CGFloat = 100
		
		switch direction {
		case .leftToRight:
			fromView.transform = .identity
			toView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8).translatedBy(x: -frame.size.width - padding, y: 0)
			
			inView.insertSubview(toView, belowSubview: fromView)
			UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
				toView.transform = .identity
				fromView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8).translatedBy(x: frame.size.width + padding, y: 0)
			}, completion: { finished in
				fromView.transform = .identity
				transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
			})
		case .rightToLeft:
			inView.insertSubview(toView, belowSubview: fromView)
			fromView.transform = .identity
			toView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8).translatedBy(x: frame.size.width + padding, y: 0)
			
			UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
				toView.transform = CGAffineTransform.identity
				fromView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8).translatedBy(x: -frame.size.width - padding, y: 0)
			}, completion: { finished in
				fromView.transform = .identity
				transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
			})
		}
	}
	
	func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
		return 0.4
	}
}
