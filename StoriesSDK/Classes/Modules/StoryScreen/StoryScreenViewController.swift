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
	func addNetworkErrorView()
	func removeNetworkErrorView()
	func updateLoadViewFrame()
	func layoutSlideViewIfNeeded()
	func showErrorAlert(error: Error)
	func restartAnimationForIOS10()
	func updateAnimationFractionComplete()
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
	
	func networkErrorViewDidTapRetryButton()
}

class StoryScreenViewController: UIViewController {
	
	var presenter: StoryScreenViewOutput!
	private var progressPropertyAnimator: UIViewPropertyAnimator?
	private var slidePropertyAnimator: UIViewPropertyAnimator?
	private let loadingView = LoaderView()
	private let networkErrorView = NetworkErrorView()
	private let closeButton = UIButton(type: .custom)
	private var progressStackView: UIStackView?
	private var animationBlock: ((CGFloat) -> Void)?
	private var progressAnimationFractionComplete: CGFloat = 0
	private lazy var slideView: SlideViewInput = {
		switch YStoriesManager.targetApp {
		case .music:
			return MusicSlideView()
		case .kinopoisk:
			return KinopoiskSlideView()
		}
	}()
	
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
		let curve: UIViewAnimationCurve = model.animationType == .contentFadeIn ? .easeOut : .linear
		slidePropertyAnimator = UIViewPropertyAnimator(duration: TimeInterval(model.animationDuration), curve: curve, animations: {})
		if #available(iOS 11.0, *) {
			slidePropertyAnimator?.pausesOnCompletion = true
		}
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
		leftTapArea.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.3).isActive = true
		
		rightTapArea.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
		rightTapArea.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
		rightTapArea.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
		rightTapArea.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.7).isActive = true
	}
	
	func addCloseButton() {
		let bundle = Bundle(for: StoryScreenViewController.self)
		closeButton.setImage(UIImage(named: "closeIcon", in: bundle, compatibleWith: nil), for: .normal)
		closeButton.addTarget(self, action: #selector(closeButtonDidTap), for: .touchUpInside)
		self.view.addSubview(closeButton)
		closeButton.translatesAutoresizingMaskIntoConstraints = false
		closeButton.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -16).isActive = true
		closeButton.heightAnchor.constraint(equalToConstant: 28).isActive = true
		closeButton.widthAnchor.constraint(equalToConstant: 28).isActive = true
		switch YStoriesManager.targetApp {
		case .music:
			closeButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 82).isActive = true
		case .kinopoisk where isIphoneX:
			closeButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 91).isActive = true
		case .kinopoisk:
			closeButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 53).isActive = true
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
	
	func addNetworkErrorView() {
		self.view.addSubview(networkErrorView)
		if let progressStackView = progressStackView {
			self.view.bringSubview(toFront: progressStackView)
		}
		self.view.bringSubview(toFront: closeButton)
		networkErrorView.delegate = self
		networkErrorView.translatesAutoresizingMaskIntoConstraints = false
		networkErrorView.leftAnchor.constraint(equalTo: slideView.leftAnchor).isActive = true
		networkErrorView.rightAnchor.constraint(equalTo: slideView.rightAnchor).isActive = true
		networkErrorView.topAnchor.constraint(equalTo: slideView.topAnchor).isActive = true
		networkErrorView.bottomAnchor.constraint(equalTo: slideView.bottomAnchor).isActive = true
	}
	
	func removeNetworkErrorView() {
		networkErrorView.removeFromSuperview()
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
		guard let slidePropertyAnimator = self.slidePropertyAnimator, slidePropertyAnimator.state == .active else { return }
		self.slidePropertyAnimator?.pauseAnimation()
	}
	
	func resumeAnimation() {
		if self.progressPropertyAnimator?.state == .active {
			self.progressPropertyAnimator?.startAnimation()
		}
		if self.slidePropertyAnimator?.state == .active {
			self.slidePropertyAnimator?.startAnimation()
		}
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
		for i in 0 ..< storyModel.data.dataSlides.count {
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
		switch YStoriesManager.targetApp {
		case .music:
			stackView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 60).isActive = true
			stackView.heightAnchor.constraint(equalToConstant: 4).isActive = true
		case .kinopoisk where isIphoneX:
			stackView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 70).isActive = true
			stackView.heightAnchor.constraint(equalToConstant: 3).isActive = true
		case .kinopoisk:
			stackView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 32).isActive = true
			stackView.heightAnchor.constraint(equalToConstant: 3).isActive = true
		}
	}
	
	private func updateProgressView(with storyModel: StoryModel, needProgressAnimation: Bool) {
		progressStackView?.arrangedSubviews.enumerated().forEach { index ,view in
			guard let view = view as? ProgressTabView else { return }
			var progressViewWidth = self.view.bounds.width - (ProgressTabView.leftRightInset * 2)
			progressViewWidth -= ProgressTabView.cellSpacing * CGFloat(storyModel.data.dataSlides.count - 1)
			progressViewWidth /= CGFloat(storyModel.data.dataSlides.count)
			switch view.progressState {
			case .notWatched:
				view.progressViewWidthConstraint?.constant = 0
			case .inProgress:
				view.progressViewWidthConstraint?.constant = 0
				view.layoutIfNeeded()
				progressPropertyAnimator?.stopAnimation(true)
				progressPropertyAnimator?.finishAnimation(at: .current)
				progressPropertyAnimator = nil
				self.progressAnimationFractionComplete = 0
				if storyModel.data.dataSlides.count > index, needProgressAnimation {
					let slideModel = storyModel.data.dataSlides[index]
					animationBlock = { [weak self] (fractionComplete: CGFloat) in
						guard let self = self else { return }
						let duration = CGFloat(slideModel.duration)
						self.progressPropertyAnimator = UIViewPropertyAnimator(duration: TimeInterval(duration * (1 - fractionComplete)), curve: .linear) {
							view.progressViewWidthConstraint?.constant = progressViewWidth
							view.layoutIfNeeded()
						}
						if #available(iOS 11.0, *) {
							self.progressPropertyAnimator?.pausesOnCompletion = true
						} else {
							self.progressPropertyAnimator?.addCompletion { _ in
								view.progressViewWidthConstraint?.constant = progressViewWidth * self.progressAnimationFractionComplete
							}
						}
					}
					animationBlock?(0)
					progressPropertyAnimator?.startAnimation()
				}
			case .watched:
				view.progressViewWidthConstraint?.constant = progressViewWidth
			}
		}
	}
	
	func restartAnimationForIOS10() {
		progressPropertyAnimator?.stopAnimation(true)
		progressPropertyAnimator?.finishAnimation(at: .current)
		progressPropertyAnimator = nil
		if self.progressAnimationFractionComplete > 0 {
			animationBlock?(self.progressAnimationFractionComplete)
			progressPropertyAnimator?.startAnimation()
		}
	}
	
	func updateAnimationFractionComplete() {
		let progressFractionComplete = self.progressPropertyAnimator?.fractionComplete ?? 0
		self.progressAnimationFractionComplete += (1 - self.progressAnimationFractionComplete) * progressFractionComplete
	}
}

extension StoryScreenViewController: NetworkErrorViewDelegate {
	func didTapRetryButton() {
		presenter.networkErrorViewDidTapRetryButton()
	}
}
