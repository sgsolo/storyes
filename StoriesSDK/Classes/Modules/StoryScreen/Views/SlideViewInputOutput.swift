
import UIKit

protocol SlideViewInput where Self: UIView {
	var delegate: SlideViewOutput? { get set }
	
	func setSlide(model: SlideViewModel)
	func performContentAnimation(model: SlideViewModel, needAnimation: Bool, propertyAnimator: UIViewPropertyAnimator?)
}

protocol SlideViewInputTrait: SlideViewInput {
	var slideViewModel: SlideViewModel? { get set }
}

protocol SlideViewOutput: class {
	func didTapOnButton(url: URL)
}
