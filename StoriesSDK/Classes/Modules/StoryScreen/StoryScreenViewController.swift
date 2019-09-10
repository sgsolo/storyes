import UIKit
import AVFoundation

protocol StoryScreenViewInput: class {
	func addSlideView()
	func addGestureRecognizers()
	func addCloseButton()
	func updateProgressView(storyModel: StoryModel, needProgressAnimation: Bool)
	func updateAnimationOnSlide(model: SlideViewModel, needAnimation: Bool)
	func pauseAnimation()
	func resumeAnimation()
	func stopAnimation()
	func showSlide(model: SlideViewModel)
	func addLoadingView()
	func removeLoadingView()
	func updateLoadViewFrame()
	func layoutSlideViewIfNeeded()
	func showErrorAlert(error: Error)
}

protocol StoryScreenViewOutput: class {
	func viewDidLoad()
	func viewWillAppear(_ animated: Bool)
	func viewDidLayoutSubviews()
	func viewDidAppear(_ animated: Bool)
	
	func touchesBegan()
	func touchesCancelled()
	func touchesEnded()
	
	func tapOnLeftSide()
	func tapOnRightSide()
	func closeButtonDidTap()
}

class StoryScreenViewController: UIViewController {
	
	var presenter: StoryScreenViewOutput!
	var progressPropertyAnimator: UIViewPropertyAnimator?
	var slidePropertyAnimator: UIViewPropertyAnimator?
	var loadingView = LoaderView()
	
	private lazy var slideView: SlideViewInput = {
		switch YStoriesManager.targetApp {
		case .music:
			return MusicSlideView()
		case .kinopoisk:
			return KinopoiskSlideView()
		}
	}()
	private var progressStackView: UIStackView?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.view.backgroundColor = .clear
		presenter.viewDidLoad()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		presenter.viewWillAppear(animated)
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		presenter.viewDidLayoutSubviews()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		presenter.viewDidAppear(animated)
	}
}

// MARK: - Actions
extension StoryScreenViewController {
	@objc private func tapOnLeftSide() {
		presenter.tapOnLeftSide()
	}
	
	@objc private func tapOnRightSide() {
		presenter.tapOnRightSide()
	}
	
	@objc private func closeButtonDidTap() {
		presenter.closeButtonDidTap()
	}
}

// MARK: - UIResponder
extension StoryScreenViewController {
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesBegan(touches, with: event)
		presenter.touchesBegan()
	}
	
	override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesCancelled(touches, with: event)
		presenter.touchesCancelled()
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesEnded(touches, with: event)
		presenter.touchesEnded()
	}
}

extension StoryScreenViewController: StoryScreenViewInput {
	func updateProgressView(storyModel: StoryModel, needProgressAnimation: Bool) {
		configureProgressView(with: storyModel)
		updateProgressView(with: storyModel, needProgressAnimation: needProgressAnimation)
	}
	
	func updateAnimationOnSlide(model: SlideViewModel, needAnimation: Bool) {
		slidePropertyAnimator?.stopAnimation(true)
		slidePropertyAnimator?.finishAnimation(at: .current)
		slidePropertyAnimator = nil
		slidePropertyAnimator = UIViewPropertyAnimator(duration: TimeInterval(model.animationDuration), curve: .linear)
		slideView.performContentAnimation(model: model, needAnimation: needAnimation, propertyAnimator: slidePropertyAnimator)
		slidePropertyAnimator?.startAnimation()
	}
	
	func addSlideView() {
		self.view.addSubview(slideView)
		slideView.translatesAutoresizingMaskIntoConstraints = false
		slideView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
		slideView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
		slideView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
		slideView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
	}
	
	func addGestureRecognizers() {
		let leftTapGestureRecognizer = ShortTapGestureRecognizer(target: self, action: #selector(tapOnLeftSide))
		let leftTapArea = UIView(frame: .zero)
		leftTapArea.translatesAutoresizingMaskIntoConstraints = false
		leftTapArea.addGestureRecognizer(leftTapGestureRecognizer)
		self.view.addSubview(leftTapArea)
		
		let rightTapArea = UIView(frame: .zero)
		rightTapArea.translatesAutoresizingMaskIntoConstraints = false
		let rightTapGestureRecognizer = ShortTapGestureRecognizer(target: self, action: #selector(tapOnRightSide))
		rightTapArea.addGestureRecognizer(rightTapGestureRecognizer)
		self.view.addSubview(rightTapArea)
		
		leftTapArea.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
		leftTapArea.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
		leftTapArea.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
		leftTapArea.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.5).isActive = true
		
		rightTapArea.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
		rightTapArea.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
		rightTapArea.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
		rightTapArea.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.5).isActive = true
	}
	
	func addCloseButton() {
		let button = UIButton(type: .custom)
		let bundle = Bundle(for: StoryScreenViewController.self)
		button.setImage(UIImage(named: "closeIcon", in: bundle, compatibleWith: nil), for: .normal)
		button.addTarget(self, action: #selector(closeButtonDidTap), for: .touchUpInside)
		self.view.addSubview(button)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -16).isActive = true
		button.heightAnchor.constraint(equalToConstant: 28).isActive = true
		button.widthAnchor.constraint(equalToConstant: 28).isActive = true
		if YStoriesManager.targetApp == .music {
			button.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 82).isActive = true
		} else if isIphoneX, YStoriesManager.targetApp == .kinopoisk {
			button.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 91).isActive = true
		} else {
			button.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 53).isActive = true
		}
	}

	func showSlide(model: SlideViewModel) {
		self.slideView.setSlide(model: model)
	}
	
	func addLoadingView() {
		slideView.addSubview(loadingView)
		loadingView.translatesAutoresizingMaskIntoConstraints = false
		loadingView.leftAnchor.constraint(equalTo: slideView.leftAnchor).isActive = true
		loadingView.rightAnchor.constraint(equalTo: slideView.rightAnchor).isActive = true
		loadingView.topAnchor.constraint(equalTo: slideView.topAnchor).isActive = true
		loadingView.bottomAnchor.constraint(equalTo: slideView.bottomAnchor).isActive = true
	}
	
	func removeLoadingView() {
		loadingView.alpha = 1
		UIView.animate(withDuration: 0.25, animations: {
			self.loadingView.alpha = 0
		}) { finish in
			self.loadingView.alpha = 1
			self.loadingView.removeFromSuperview()
		}
		
	}
	
	func updateLoadViewFrame() {
		loadingView.frame = self.view.bounds
	}
	
	func layoutSlideViewIfNeeded() {
		slideView.setNeedsLayout()
		slideView.layoutIfNeeded()
	}
	
	func stopAnimation() {
		progressPropertyAnimator?.stopAnimation(true)
		progressPropertyAnimator?.finishAnimation(at: .current)
		progressPropertyAnimator = nil
		
		slidePropertyAnimator?.stopAnimation(true)
		slidePropertyAnimator?.finishAnimation(at: .current)
		slidePropertyAnimator = nil
	}
	
	func pauseAnimation() {
		guard let progressAnimator = self.progressPropertyAnimator, progressAnimator.state == .active else { return }
		self.progressPropertyAnimator?.pauseAnimation()
		
		self.slidePropertyAnimator?.pauseAnimation()
	}
	
	func resumeAnimation() {
		self.progressPropertyAnimator?.startAnimation()
		
		self.slidePropertyAnimator?.startAnimation()
	}
	
	func showErrorAlert(error: Error) {
		let alert = UIAlertController(title: "Ошибка", message: error.localizedDescription, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "ок", style: .default, handler: nil))
		self.present(alert, animated: true)
	}
}

extension StoryScreenViewController {
	private func configureProgressView(with storyModel: StoryModel) {
		var arrangedSubviews: [UIView] = []
		for i in 0 ..< storyModel.dataSlides.count {
			var state: ProgressState
			let currentIndex = storyModel.currentIndex
			if i < currentIndex {
				state = .watched
			} else if i == currentIndex {
				state = .inProgress
			} else {
				state = .notWatched
			}
			let tabView = ProgressTabView(frame: .zero)
			tabView.progressState = state
			arrangedSubviews.append(tabView)
		}
		let stackView = UIStackView(arrangedSubviews: arrangedSubviews)
		progressStackView?.removeFromSuperview()
		progressStackView = stackView
		stackView.spacing = 8
		stackView.alignment = .fill
		stackView.distribution = .fillEqually
		self.view.addSubview(stackView)
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 16).isActive = true
		stackView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -16).isActive = true
		if YStoriesManager.targetApp == .music {
			stackView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 60).isActive = true
			stackView.heightAnchor.constraint(equalToConstant: 4).isActive = true
		} else if isIphoneX, YStoriesManager.targetApp == .kinopoisk {
			stackView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 70).isActive = true
			stackView.heightAnchor.constraint(equalToConstant: 3).isActive = true
		} else {
			stackView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 32).isActive = true
			stackView.heightAnchor.constraint(equalToConstant: 3).isActive = true
		}
	}
	
	private func updateProgressView(with storyModel: StoryModel, needProgressAnimation: Bool) {
		progressStackView?.arrangedSubviews.enumerated().forEach { index ,view in
			guard let view = view as? ProgressTabView else { return }
			var progressViewWidth = self.view.bounds.width - (ProgressTabView.leftRightInset * 2)
			progressViewWidth -= ProgressTabView.cellSpacing * CGFloat(storyModel.dataSlides.count - 1)
			progressViewWidth /= CGFloat(storyModel.dataSlides.count)
			switch view.progressState {
			case .notWatched:
				view.progressViewWidthConstraint?.constant = 0
			case .inProgress:
				view.progressViewWidthConstraint?.constant = 0
				view.layoutIfNeeded()
				progressPropertyAnimator?.stopAnimation(true)
				progressPropertyAnimator?.finishAnimation(at: .current)
				progressPropertyAnimator = nil
				if storyModel.dataSlides.count > index, needProgressAnimation {
					let slideModel = storyModel.dataSlides[index]
					progressPropertyAnimator = UIViewPropertyAnimator(duration: TimeInterval(slideModel.duration), curve: .linear) {
						view.progressViewWidthConstraint?.constant = progressViewWidth
						view.layoutIfNeeded()
					}
					progressPropertyAnimator?.startAnimation()
				}
			case .watched:
				view.progressViewWidthConstraint?.constant = progressViewWidth
			}
		}
	}
}
