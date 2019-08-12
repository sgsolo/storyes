import UIKit

public class FullScreenPresentAnimation: NSObject, UIViewControllerAnimatedTransitioning {
	
	let startFrame: CGRect
	
	public init(startFrame: CGRect) {
		self.startFrame = startFrame
	}
	
	public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
		return 0.25
	}
	
	public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
		guard let toViewController = transitionContext.viewController(forKey: .to), let snapshotView = toViewController.view.snapshotView(afterScreenUpdates: true) else { return }
		transitionContext.containerView.addSubview(snapshotView)
		snapshotView.frame = self.startFrame
		snapshotView.layer.cornerRadius = 4
		snapshotView.layer.masksToBounds = true
		snapshotView.alpha = 0
		
		let duration = self.transitionDuration(using: transitionContext)
		UIView.animate(withDuration: duration, animations: {
			snapshotView.layer.cornerRadius = 0
			snapshotView.alpha = 1
			snapshotView.frame = transitionContext.containerView.frame
		}, completion: { _ in
			transitionContext.containerView.addSubview(toViewController.view)
			snapshotView.removeFromSuperview()
			transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
		})
	}
}

public class FullScreenDismissedAnimation: NSObject, UIViewControllerAnimatedTransitioning {
	
	let endFrame: CGRect
	
	public init(endFrame: CGRect) {
		self.endFrame = endFrame
	}
	
	public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
		return 0.25
	}
	
	public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
		guard let fromViewController = transitionContext.viewController(forKey: .from),
			let toViewController = transitionContext.viewController(forKey: .to),
			let toSnapshotView = toViewController.view.snapshotView(afterScreenUpdates: true),
			let fromSnapshotView = fromViewController.view.snapshotView(afterScreenUpdates: true) else { return }
		transitionContext.containerView.addSubview(toSnapshotView)
		transitionContext.containerView.addSubview(fromSnapshotView)
		fromSnapshotView.layer.masksToBounds = true
		fromSnapshotView.alpha = 1
		
		let duration = self.transitionDuration(using: transitionContext)
		UIView.animate(withDuration: duration, animations: {
			fromSnapshotView.layer.cornerRadius = 4
			fromSnapshotView.alpha = 0
			fromSnapshotView.frame = self.endFrame
		}, completion: { _ in
			transitionContext.containerView.addSubview(fromViewController.view)
			fromSnapshotView.removeFromSuperview()
			transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
		})
	}
}
