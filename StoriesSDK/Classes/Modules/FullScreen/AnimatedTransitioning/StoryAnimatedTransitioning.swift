import UIKit

enum Direction {
	case leftToRight
	case rightToLeft
}

class StoryAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
	
	let direction: Direction
	let transitionDuration: CGFloat = 0.25
	let scale: CGFloat = 0.8
	
	init(direction: Direction) {
		self.direction = direction
		super.init()
	}
	
	func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
		return TimeInterval(transitionDuration)
	}
	
	func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
		guard let transitionContext = transitionContext as? StoryContextTransitioning else { return }
		let percentComplete = transitionContext.percentComplete
		if !transitionContext.transitionWasCancelled {
			animateFinishTransition(using: transitionContext, percentComplete: percentComplete)
		} else {
			animateCancelledTransition(using: transitionContext, percentComplete: percentComplete)
		}
	}
	
	func setStartPosition(using transitionContext: UIViewControllerContextTransitioning) {
		let inView = transitionContext.containerView
		guard let toView = transitionContext.view(forKey: .to),
			let fromView = transitionContext.view(forKey: .from) else { return }
		let frame = inView.bounds
		
		inView.insertSubview(toView, belowSubview: fromView)
		fromView.transform = .identity
		fromView.center = CGPoint(x: frame.size.width / 2, y: fromView.center.y)
		toView.transform = CGAffineTransform(scaleX: scale, y: scale)
		switch direction {
		case .leftToRight:
			toView.center = CGPoint(x: -frame.size.width * (1/2 + (1 - scale)), y: toView.center.y)
		case .rightToLeft:
			toView.center = CGPoint(x: frame.size.width * (3/2 + (1 - scale)), y: toView.center.y)
		}
	}
	
	func updatePosition(using transitionContext: UIViewControllerContextTransitioning, percentComplete: CGFloat) {
		let inView = transitionContext.containerView
		guard let toView = transitionContext.view(forKey: .to),
			let fromView = transitionContext.view(forKey: .from) else { return }
		
		let frame = inView.bounds
		
		let scaleFactorTo = scale + percentComplete * (1 - scale)
		let xOffsetTo = frame.size.width * (1 - percentComplete)
		
		let scaleFactorFrom = 1 - percentComplete * (1 - scale)
		let xOffsetFrom = frame.size.width * percentComplete
		
		UIView.animate(withDuration: 0.1, animations: {
			fromView.transform = CGAffineTransform(scaleX: scaleFactorFrom, y: scaleFactorFrom)
			toView.transform = CGAffineTransform(scaleX: scaleFactorTo, y: scaleFactorTo)
			switch self.direction {
			case .leftToRight:
				fromView.center = CGPoint(x: xOffsetFrom + frame.size.width / 2, y: fromView.center.y)
				toView.center = CGPoint(x: -xOffsetTo + frame.size.width / 2, y: toView.center.y)
			case .rightToLeft:
				fromView.center = CGPoint(x: -xOffsetFrom + frame.size.width / 2, y: fromView.center.y)
				toView.center = CGPoint(x: xOffsetTo + frame.size.width / 2, y: toView.center.y)
			}
		})
	}
	
	func animateCancelledTransition(using transitionContext: UIViewControllerContextTransitioning, percentComplete: CGFloat) {
		guard let toView = transitionContext.view(forKey: .to),
			let fromView = transitionContext.view(forKey: .from)  else { return }
		let inView = transitionContext.containerView
		let frame = inView.bounds
		
		UIView.animate(withDuration: TimeInterval(transitionDuration * (1 - percentComplete)), animations: {
			fromView.transform = .identity
			fromView.center = CGPoint(x: frame.size.width / 2, y: fromView.center.y)
			toView.transform = CGAffineTransform(scaleX: self.scale, y: self.scale)
			switch self.direction {
			case .leftToRight:
				toView.center = CGPoint(x: -frame.size.width / 2, y: fromView.center.y)
			case .rightToLeft:
				toView.center = CGPoint(x: 3/2 * frame.size.width, y: fromView.center.y)
			}
		},  completion: { finished in
			transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
		})
	}
	
	func animateFinishTransition(using transitionContext: UIViewControllerContextTransitioning, percentComplete: CGFloat) {
		guard let toView = transitionContext.view(forKey: .to),
			let fromView = transitionContext.view(forKey: .from)  else { return }
		let inView = transitionContext.containerView
		let frame = inView.bounds
		UIView.animate(withDuration: TimeInterval(transitionDuration * (1 - percentComplete)), animations: {
			toView.transform = .identity
			toView.center = CGPoint(x: frame.size.width / 2, y: fromView.center.y)
			fromView.transform = CGAffineTransform(scaleX: self.scale, y: self.scale)
			switch self.direction {
			case .leftToRight:
				fromView.center = CGPoint(x: 3/2 * frame.size.width, y: fromView.center.y)
			case .rightToLeft:
				fromView.center = CGPoint(x: -frame.size.width / 2, y: fromView.center.y)
			}
		}, completion: { finished in
			transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
		})
	}
}
