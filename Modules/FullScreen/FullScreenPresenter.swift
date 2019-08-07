import Foundation

//protocol FullScreenPresenterInput: class {
//}
//
//TODO: StoryModel для теста вьюхи, после удалить
struct SlideModel {
	let duration = 6
	var color: UIColor
	var image: UIImage?
}

struct StoryIndexPath {
	var currentStory: Int = 1 {
		didSet {
			currentSlide = 0
		}
	}
	var currentSlide: Int = 0
}

class FullScreenPresenter {
	weak var output: FullScreenModuleOutput!
	weak var view: FullScreenViewInput!
	
	private var slideSwitchTimer: Timer?
	private var pauseStartDate: Date?
	private var previousFireDate: Date?
	
	var storyIndexPath = StoryIndexPath()
	let sectionData = CollectionSectionData(objects:
		[
			[SlideModel(color: .red, image: UIImage(named: "1", in: Bundle(for: FullScreenPresenter.self), compatibleWith: nil)),
			 SlideModel(color: .blue, image: UIImage(named: "2", in: Bundle(for: FullScreenPresenter.self), compatibleWith: nil)),
			 SlideModel(color: .brown, image: UIImage(named: "3", in: Bundle(for: FullScreenPresenter.self), compatibleWith: nil)),
			 SlideModel(color: .green, image: UIImage(named: "4", in: Bundle(for: FullScreenPresenter.self), compatibleWith: nil)),
			 SlideModel(color: .purple, image: UIImage(named: "5", in: Bundle(for: FullScreenPresenter.self), compatibleWith: nil))]
			,
			[SlideModel(color: .red, image: UIImage(named: "1", in: Bundle(for: FullScreenPresenter.self), compatibleWith: nil)),
			 SlideModel(color: .blue, image: UIImage(named: "2", in: Bundle(for: FullScreenPresenter.self), compatibleWith: nil)),
			 SlideModel(color: .brown, image: UIImage(named: "3", in: Bundle(for: FullScreenPresenter.self), compatibleWith: nil)),
			 SlideModel(color: .green, image: UIImage(named: "4", in: Bundle(for: FullScreenPresenter.self), compatibleWith: nil)),
			 SlideModel(color: .purple, image: UIImage(named: "5", in: Bundle(for: FullScreenPresenter.self), compatibleWith: nil))]
		])
}

extension FullScreenPresenter: FullScreenViewOutput {
	func loadView() {
		view.configureCollectionView()
		updateData()
		scrollToStory(index: storyIndexPath.currentStory, animated: false)
		showSlide()
	}
	
	func viewDidDisappear(_ animated: Bool) {
		invalidateTimer()
	}
	
	//TODO: брать TimeInterval из модели слайда
	private func runTimerForSlide() {
		invalidateTimer()
		self.pauseStartDate = nil
		self.previousFireDate = nil
		self.slideSwitchTimer = Timer.scheduledTimer(withTimeInterval: 6, repeats: true, block: { [weak self] timer in
			self?.showNextSlide()
		})
	}
	
	private func invalidateTimer() {
		self.slideSwitchTimer?.invalidate()
		self.slideSwitchTimer = nil
		
		self.pauseStartDate = nil
		self.previousFireDate = nil
	}
	
	private func pauseTimer() {
		guard let timer = self.slideSwitchTimer, self.previousFireDate == nil else { return }
		self.pauseStartDate = Date()
		self.previousFireDate = timer.fireDate
		timer.fireDate = Date.distantFuture
	}
	
	private func resumeTimer() {
		guard let pauseStartDate = self.pauseStartDate, let previousFireDate = self.previousFireDate else { return }
		let pauseTime = pauseStartDate.timeIntervalSinceNow * -1
		self.slideSwitchTimer?.fireDate = Date(timeInterval: pauseTime, since: previousFireDate)
	}
	
	private func showSlide() {
		if sectionData.objects.count > storyIndexPath.currentStory,
			let slideModels = sectionData.objects[storyIndexPath.currentStory] as? [SlideModel],
			slideModels.count > storyIndexPath.currentSlide {
			let slideModel = slideModels[storyIndexPath.currentSlide]
			showSlide(model: slideModel, modelsCount: slideModels.count, modelIndex: storyIndexPath.currentSlide)
		}
		runTimerForSlide()
	}
	
	private func updateData() {
		view.updateData(with: [sectionData])
	}
	
	private func scrollToStory(index: Int, animated: Bool) {
		if animated {
			view.setCollectionViewUserInteractionEnabled(false)
		}
		view.scrollToStory(index: index, animated: animated)
		if !animated {
			view.resumeAnimation()
			resumeTimer()
		}
	}
	
	private func showSlide(model: SlideModel, modelsCount: Int, modelIndex: Int) {
		view.showSlide(model: model, modelsCount: modelsCount, modelIndex: modelIndex)
	}
	
	func storyCellDidTapOnLeftSide() {
		assert(Thread.isMainThread)
		view.setCollectionViewScrollEnabled(true)
		showPrevSlide()
	}
	
	private func showPrevSlide() {
		if sectionData.objects.count > storyIndexPath.currentStory,
			storyIndexPath.currentSlide - 1 >= 0 {
			storyIndexPath.currentSlide -= 1
			showSlide()
		} else if sectionData.objects.count > storyIndexPath.currentStory,
			storyIndexPath.currentStory - 1 >= 0  {
			storyIndexPath.currentStory -= 1
			scrollToStory(index: storyIndexPath.currentStory, animated: true)
			showSlide()
		} else if storyIndexPath.currentStory == 0,
			storyIndexPath.currentSlide == 0 {
			output.fullScreenStoriesDidEnd()
		}
	}
	
	func storyCellDidTapOnRightSide() {
		assert(Thread.isMainThread)
		view.setCollectionViewScrollEnabled(true)
		showNextSlide()
	}
	
	private func showNextSlide() {
		if sectionData.objects.count > storyIndexPath.currentStory,
			let slideModels = sectionData.objects[storyIndexPath.currentStory] as? [SlideModel],
			slideModels.count > storyIndexPath.currentSlide + 1 {
			storyIndexPath.currentSlide += 1
			showSlide()
		} else if sectionData.objects.count > storyIndexPath.currentStory,
			let slideModels = sectionData.objects[storyIndexPath.currentStory] as? [SlideModel],
			slideModels.count == storyIndexPath.currentSlide + 1,
			sectionData.objects.count == storyIndexPath.currentStory + 1 {
			output.fullScreenStoriesDidEnd()
		} else if sectionData.objects.count > storyIndexPath.currentStory,
			let slideModels = sectionData.objects[storyIndexPath.currentStory] as? [SlideModel],
			slideModels.count > storyIndexPath.currentStory + 1 {
			storyIndexPath.currentStory += 1
			scrollToStory(index: storyIndexPath.currentStory, animated: true)
			showSlide()
		}
	}
	
	func storyCellTouchesBegan() {
//		view.setCollectionViewScrollEnabled(false)
		pauseTimer()
		view.pauseAnimation()
	}
	
	func storyCellTouchesCancelled() {
		view.setCollectionViewScrollEnabled(true)
		resumeTimer()
		view.resumeAnimation()
	}
	
	func storyCellDidTouchesEnded() {
		view.setCollectionViewScrollEnabled(true)
		resumeTimer()
		view.resumeAnimation()
	}
	
	func didEndScrollingAnimation() {
		view.setCollectionViewUserInteractionEnabled(true)
		resumeTimer()
		view.resumeAnimation()
	}
	
	func collectionViewDidScroll(contentSize: CGSize, contentOffset: CGPoint) {
		let margin: CGFloat = 40
		if contentSize.width + margin < contentOffset.x + UIScreen.main.bounds.width {
			output.fullScreenStoriesDidEnd()
		}
		pauseTimer()
		view.pauseAnimation()
	}
	
	func collectionViewDidEndDecelerating(visibleIndexPath: IndexPath) {
		if visibleIndexPath.item != storyIndexPath.currentStory {
			storyIndexPath.currentStory = visibleIndexPath.item
			runTimerForSlide()
		}
		view.setCollectionViewScrollEnabled(true)
		resumeTimer()
		view.resumeAnimation()
	}
	
	func closeButtonDidTap() {
		output.fullScreenDidTapOnCloseButton()
	}
}

extension FullScreenPresenter: FullScreenModuleInput {
	
}
