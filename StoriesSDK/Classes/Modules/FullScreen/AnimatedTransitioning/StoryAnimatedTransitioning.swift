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
		
		switch direction {
		case .leftToRight:
			inView.insertSubview(toView, belowSubview: fromView)
			fromView.transform = .identity
			toView.transform = CGAffineTransform(scaleX: scale, y: scale).translatedBy(x: -frame.size.width, y: 0)
		case .rightToLeft:
			inView.insertSubview(toView, belowSubview: fromView)
			fromView.transform = .identity
			toView.transform = CGAffineTransform(scaleX: scale, y: scale).translatedBy(x: frame.size.width, y: 0)
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
		
		switch direction {
		case .leftToRight:
			fromView.center = CGPoint(x: xOffsetFrom + frame.size.width / 2, y: fromView.center.y)
			fromView.transform = CGAffineTransform(scaleX: scaleFactorFrom, y: scaleFactorFrom)
			toView.center = CGPoint(x: -xOffsetTo + frame.size.width / 2, y: toView.center.y)
			toView.transform = CGAffineTransform(scaleX: scaleFactorTo, y: scaleFactorTo)
		case .rightToLeft:
			fromView.transform = CGAffineTransform(scaleX: scaleFactorFrom, y: scaleFactorFrom)
			fromView.center = CGPoint(x: -xOffsetFrom + frame.size.width / 2, y: fromView.center.y)
			toView.transform = CGAffineTransform(scaleX: scaleFactorTo, y: scaleFactorTo)
			toView.center = CGPoint(x: xOffsetTo + frame.size.width / 2, y: toView.center.y)
		}
	}
	
	func animateCancelledTransition(using transitionContext: UIViewControllerContextTransitioning, percentComplete: CGFloat) {
		guard let toView = transitionContext.view(forKey: .to),
			let fromView = transitionContext.view(forKey: .from)  else { return }
		let inView = transitionContext.containerView
		let frame = inView.bounds
		
		switch direction {
		case .leftToRight:
			UIView.animate(withDuration: TimeInterval(transitionDuration * (1 - percentComplete)), animations: {
				fromView.transform = .identity
				fromView.center = CGPoint(x: frame.size.width / 2, y: fromView.center.y)
				toView.transform = CGAffineTransform(scaleX: self.scale, y: self.scale)
				toView.center = CGPoint(x: -frame.size.width / 2, y: fromView.center.y)
			}, completion: { finished in
				transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
			})
		case .rightToLeft:
			UIView.animate(withDuration: TimeInterval(transitionDuration * (1 - percentComplete)), animations: {
				fromView.transform = .identity
				fromView.center = CGPoint(x: frame.size.width / 2, y: fromView.center.y)
				toView.transform = CGAffineTransform(scaleX: self.scale, y: self.scale)
				toView.center = CGPoint(x: 1.5 * frame.size.width, y: fromView.center.y)
			}, completion: { finished in
				transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
			})
		}
	}
	
	func animateFinishTransition(using transitionContext: UIViewControllerContextTransitioning, percentComplete: CGFloat) {
		guard let toView = transitionContext.view(forKey: .to),
			let fromView = transitionContext.view(forKey: .from)  else { return }
		let inView = transitionContext.containerView
		let frame = inView.bounds
		
		switch direction {
		case .leftToRight:
			UIView.animate(withDuration: TimeInterval(transitionDuration * (1 - percentComplete)), animations: {
				toView.transform = .identity
				toView.center = CGPoint(x: frame.size.width / 2, y: fromView.center.y)
				fromView.transform = CGAffineTransform(scaleX: self.scale, y: self.scale)
				fromView.center = CGPoint(x: 1.5 * frame.size.width, y: fromView.center.y)
			}, completion: { finished in
				transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
			})
		case .rightToLeft:
			UIView.animate(withDuration: TimeInterval(transitionDuration * (1 - percentComplete)), animations: {
				toView.transform = .identity
				toView.center = CGPoint(x: frame.size.width / 2, y: fromView.center.y)
				fromView.transform = CGAffineTransform(scaleX: self.scale, y: self.scale)
				fromView.center = CGPoint(x: -frame.size.width / 2, y: fromView.center.y)
			}, completion: { finished in
				transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
			})
		}
	}
}
