import UIKit

class StoryContextTransitioning: NSObject, UIViewControllerContextTransitioning {
	
	var viewControllers: [UITransitionContextViewControllerKey : UIViewController]
	var views: [UITransitionContextViewKey : UIView]
	var completeTransition: ((_ didComplete: Bool) -> Void)?
	var containerView: UIView
	var isAnimated: Bool = true
	var isInteractive: Bool = true
	var transitionWasCancelled: Bool = false
	var presentationStyle: UIModalPresentationStyle = .custom
	var targetTransform: CGAffineTransform = CGAffineTransform()
	
	init(from: UIViewController, to: UIViewController) {
		self.containerView = from.view.superview ?? UIView()
		viewControllers = [UITransitionContextViewControllerKey.to: to,
						   UITransitionContextViewControllerKey.from: from]
		views = [UITransitionContextViewKey.to: to.view,
				 UITransitionContextViewKey.from: from.view]
		super.init()
	}
	
	func updateInteractiveTransition(_ percentComplete: CGFloat) {
	}
	
	func finishInteractiveTransition() {
		transitionWasCancelled = false
	}
	
	func cancelInteractiveTransition() {
		//TODO: фикс мигагния при отмене интерактивного перехода
		views[.to]?.isHidden = true
		views[.to]?.frame = CGRect.zero
		views[.to]?.setNeedsLayout()
		views[.to]?.layoutIfNeeded()
		
		transitionWasCancelled = true
	}
	
	func pauseInteractiveTransition() {
	}
	
	func completeTransition(_ didComplete: Bool) {
		completeTransition?(didComplete)
	}
	
	func viewController(forKey key: UITransitionContextViewControllerKey) -> UIViewController? {
		return viewControllers[key]
	}
	
	func view(forKey key: UITransitionContextViewKey) -> UIView? {
		return views[key]
	}
	
	func initialFrame(for vc: UIViewController) -> CGRect {
		return UIScreen.main.bounds
	}
	
	func finalFrame(for vc: UIViewController) -> CGRect {
		return UIScreen.main.bounds
	}
}
