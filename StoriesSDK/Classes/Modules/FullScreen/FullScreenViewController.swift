import UIKit

protocol FullScreenViewInput: class {
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
	
	override public func loadView() {
		super.loadView()
		presenter.loadView()
	}
}

extension FullScreenViewController: FullScreenViewInput {
	
	func addPanGestureRecognizer() {
		let pan = UIPanGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
		view.addGestureRecognizer(pan)
	}
	
	func showInitialStory(storyModel: StoryModel) {
		let controller = StoryScreenViewController()
		let moduleInput = StoryScreenAssembly.setup(controller, delegate: self)
		moduleInput.storyModel = storyModel
		self.addChildViewController(controller)
		controller.view.frame = self.view.frame
		controller.view.backgroundColor = .black
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
		
		if gesture.state == .began {
			let velocity = gesture.velocity(in: gesture.view)
			direction = velocity.x > 0 ? .leftToRight : .rightToLeft
			presenter.panGestureRecognizerBegan(direction: direction)
		} else if gesture.state == .changed {
			interactionController?.updateInteractiveTransition(percentComplete: percent)
		} else if gesture.state == .ended || gesture.state == .cancelled {
			let velocity = gesture.velocity(in: gesture.view)
			let cond = direction == .leftToRight ? velocity.x > 0 : velocity.x < 0
			if (percent > 0.5 && velocity.x == 0) || cond {
				interactionController?.finishInteractiveTransition()
			} else {
				interactionController?.cancelInteractiveTransition()
			}
			interactionController = nil
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
