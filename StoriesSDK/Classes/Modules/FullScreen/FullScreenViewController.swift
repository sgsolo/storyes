import UIKit

protocol FullScreenViewInput: class {
	func addBackgroundView()
	func addPanGestureRecognizer()
	func showStory(storyModel: StoryModel, direction: Direction)
	func showInitialStory(storyModel: StoryModel)
	func startInteractiveTransition(storyModel: StoryModel)
}

protocol FullScreenViewOutput: class {
	func loadView()
	func panGestureRecognizerBegan(direction: Direction)
	func interactiveTransitionDidEnd(direction: Direction)
	
	func closeButtonDidTap()
	func needShowPrevStory()
	func needShowNextStory()
}

public final class FullScreenViewController: UIViewController {
	var presenter: FullScreenViewOutput!
	var interactionController: StoryInteractiveTransitioning?
	var direction: Direction = .leftToRight
	var fromVC: StoryScreenViewController?
	var fromModuleInput: StoryScreenModuleInput?
	var backgroundView = UIView()
	var isInteractiveDismiss = false
	
	override public func loadView() {
		super.loadView()
		self.modalPresentationStyle = .overCurrentContext
		self.view.backgroundColor = .clear
		presenter.loadView()
		
	}
	
	override public var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
}

extension FullScreenViewController: FullScreenViewInput {
	
	func addBackgroundView() {
		self.view.addSubview(backgroundView)
		backgroundView.backgroundColor = .black
		backgroundView.translatesAutoresizingMaskIntoConstraints = false
		backgroundView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
		backgroundView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
		backgroundView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
		backgroundView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
	}
	
	func addPanGestureRecognizer() {
		let pan = UIPanGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
//		pan.delegate
		view.addGestureRecognizer(pan)
	}
	
	func showInitialStory(storyModel: StoryModel) {
		let controller = StoryScreenViewController()
		let moduleInput = StoryScreenAssembly.setup(controller, delegate: self)
		moduleInput.storyModel = storyModel
		self.addChildViewController(controller)
		controller.view.frame = self.view.frame
		self.view.addSubview(controller.view)
		controller.didMove(toParentViewController: self)
		fromVC = controller
		fromModuleInput = moduleInput
	}
	
	func showStory(storyModel: StoryModel, direction: Direction) {
		guard let fromVC = fromVC, let fromModuleInput = fromModuleInput else { return }
		let controller = StoryScreenViewController()
		let moduleInput = StoryScreenAssembly.setup(controller, delegate: self)
		moduleInput.storyModel = storyModel
		self.addChildViewController(controller)
		self.view.addSubview(controller.view)
		
		fromModuleInput.pauseStoryScreen()
		fromModuleInput.isTransitionInProgress = true
		fromModuleInput.stopAnimation()
		fromModuleInput.invalidateTimer()
		
		fromVC.willMove(toParentViewController: nil)
		controller.beginAppearanceTransition(true, animated: true)
		fromVC.beginAppearanceTransition(false, animated: true)
		
		let storyAnimatedTransitioning = StoryAnimatedTransitioning(direction: direction)
		let privateAnimatedTransition = StoryContextTransitioning(from: fromVC, to: controller)
		privateAnimatedTransition.completeTransition = { _ in
			fromVC.view.removeFromSuperview()
			fromVC.removeFromParentViewController()
			fromVC.endAppearanceTransition()
			
			controller.endAppearanceTransition()
			controller.didMove(toParentViewController: self)
			
			self.fromVC = controller
			self.fromModuleInput = moduleInput
		}
		storyAnimatedTransitioning.animateTransition(using: privateAnimatedTransition)
	}
}

extension FullScreenViewController: StoryScreenModuleOutput {
	func needShowPrevStory() {
		presenter.needShowPrevStory()
	}
	
	func needShowNextStory() {
		presenter.needShowNextStory()
	}

	func closeButtonDidTap() {
		presenter.closeButtonDidTap()
	}
}

extension FullScreenViewController {
	@objc func handleGesture(_ gesture: UIPanGestureRecognizer) {
		guard let gestureView = gesture.view else { return }
		let translate = gesture.translation(in: gestureView)
		let percent = abs(translate.x) / gestureView.bounds.size.width
		var percentY = translate.y / gestureView.bounds.size.height
		percentY = percentY >= 0 ? percentY : 0
		
		if gesture.state == .began {
			let velocity = gesture.velocity(in: gesture.view)
			if velocity.y > abs(velocity.x) {
				isInteractiveDismiss = true
				fromModuleInput?.pauseStoryScreen()
				fromModuleInput?.isTransitionInProgress = true
			} else {
				isInteractiveDismiss = false
				direction = velocity.x > 0 ? .leftToRight : .rightToLeft
				presenter.panGestureRecognizerBegan(direction: direction)
			}
		} else if gesture.state == .changed {
			if isInteractiveDismiss {
				let scaleXY = 1 - (percentY / 10)
				let translatedByY = (self.view.bounds.size.height / 2) * percentY
				fromVC?.view.transform = CGAffineTransform(scaleX: scaleXY, y: scaleXY).translatedBy(x: 0, y: translatedByY)
				backgroundView.backgroundColor = backgroundView.backgroundColor?.withAlphaComponent(1 - (percentY / 2))
			} else {
				interactionController?.updateInteractiveTransition(percentComplete: percent)
			}
		} else if gesture.state == .ended || gesture.state == .cancelled {
			let velocity = gesture.velocity(in: gesture.view)
			if isInteractiveDismiss {
				if percentY > 0.3 {
					fromModuleInput?.stopAnimation()
					fromModuleInput?.invalidateTimer()
					self.backgroundView.backgroundColor = self.backgroundView.backgroundColor?.withAlphaComponent(0)
					presenter.closeButtonDidTap()
				} else {
					UIView.animate(withDuration: 0.25, animations: {
						self.fromVC?.view.transform = .identity
						self.backgroundView.backgroundColor = .black
					}, completion: { _ in
						self.fromModuleInput?.isTransitionInProgress = false
						self.fromModuleInput?.resumeStoryScreen()
						self.fromModuleInput?.runStoryActivityIfNeeded()
					})
				}
			} else {
				let cond = direction == .leftToRight ? velocity.x > 0 : velocity.x < 0
				if (percent > 0.5 && velocity.x == 0) || cond {
					interactionController?.finishInteractiveTransition()
				} else {
					interactionController?.cancelInteractiveTransition()
				}
				interactionController = nil
			}
		}
	}
	
	func startInteractiveTransition(storyModel: StoryModel) {
		guard let fromVC = fromVC, let fromModuleInput = fromModuleInput else { return }
		let controller = StoryScreenViewController()
		let moduleInput = StoryScreenAssembly.setup(controller, delegate: self)
		moduleInput.storyModel = storyModel
		
		fromModuleInput.pauseStoryScreen()
		fromModuleInput.isTransitionInProgress = true
		
		fromVC.willMove(toParentViewController: nil)
		controller.beginAppearanceTransition(true, animated: true)
		fromVC.beginAppearanceTransition(false, animated: true)
		
		let storyAnimatedTransitioning = StoryAnimatedTransitioning(direction: direction)
		let privateAnimatedTransition = StoryContextTransitioning(from: fromVC, to: controller)
		privateAnimatedTransition.completeTransition = { didComplete in
			if didComplete {
				self.addChildViewController(controller)
				self.view.addSubview(controller.view)
				controller.endAppearanceTransition()
				
				fromModuleInput.stopAnimation()
				fromModuleInput.invalidateTimer()
				
				fromVC.view.removeFromSuperview()
				fromVC.removeFromParentViewController()
				fromVC.endAppearanceTransition()
				controller.didMove(toParentViewController: self)
				
				self.fromVC = controller
				self.fromModuleInput = moduleInput
				self.presenter.interactiveTransitionDidEnd(direction: self.direction)
			} else {
//				self.fromVC.endAppearanceTransition()
				controller.view.removeFromSuperview()
				controller.removeFromParentViewController()
				fromModuleInput.isTransitionInProgress = false
				fromModuleInput.resumeStoryScreen()
				fromModuleInput.runStoryActivityIfNeeded()
			}
		}
		interactionController = StoryInteractiveTransitioning(animator: storyAnimatedTransitioning)
		interactionController?.startInteractiveTransition(privateAnimatedTransition)
	}
}
