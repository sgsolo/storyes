
import Foundation

protocol SlideViewInput where Self: UIView {
	func setSlide(model: SlideViewModel)
	func performContentAnimation(model: SlideViewModel, needAnimation: Bool, propertyAnimator: UIViewPropertyAnimator?)
}
