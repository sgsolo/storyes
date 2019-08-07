import UIKit

protocol FullScreenViewInput: class {
	func configureCollectionView()
	func setCollectionViewScrollEnabled(_ isEnabled: Bool)
	func setCollectionViewUserInteractionEnabled(_ isEnabled: Bool)
	func updateData(with objects: [CollectionSectionData])
	func scrollToStory(index: Int, animated: Bool)
	func showSlide(model: SlideModel, modelsCount: Int, modelIndex: Int)
	func resumeAnimation()
	func pauseAnimation()
}

protocol FullScreenViewOutput: class {
	func loadView()
	func viewDidDisappear(_ animated: Bool)
	
	func storyCellDidTapOnLeftSide()
	func storyCellDidTapOnRightSide()
	func storyCellTouchesBegan()
	func storyCellTouchesCancelled()
	func storyCellDidTouchesEnded()
	
	func didEndScrollingAnimation()
	func collectionViewDidScroll(contentSize: CGSize, contentOffset: CGPoint)
	func collectionViewDidEndDecelerating(visibleIndexPath: IndexPath)
	func closeButtonDidTap()
}

public final class FullScreenViewController: UIViewController {
	var presenter: FullScreenViewOutput!
	var collectionViewAdapter: FullScreenCollectionViewAdapterInput!
	
	private var collectionView: UICollectionView = {
		let layout = PagedSliderFlowLayout(inset: 0)
		layout.minimumInteritemSpacing = 0
		layout.minimumLineSpacing = 0
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
		return collectionView
	}()
	
	override public func loadView() {
		super.loadView()
		presenter.loadView()
	}
	
	override public func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		presenter.viewDidDisappear(animated)
	}
}

extension FullScreenViewController: FullScreenViewInput {
	func configureCollectionView() {
		self.view.addSubview(collectionView)
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		collectionView.decelerationRate = UIScrollViewDecelerationRateFast
		collectionView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
		collectionView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
		collectionView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
		collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
		
		collectionViewAdapter.collectionView = collectionView
	}
	
	func setCollectionViewScrollEnabled(_ isEnabled: Bool) {
		collectionView.isScrollEnabled = isEnabled
	}
	
	func setCollectionViewUserInteractionEnabled(_ isEnabled: Bool) {
		collectionView.isUserInteractionEnabled = isEnabled
	}
	
	func updateData(with objects: [CollectionSectionData]) {
		collectionViewAdapter.updateData(with: objects)
	}
	
	func scrollToStory(index: Int, animated: Bool) {
		guard collectionView.numberOfSections > 0, collectionView.numberOfItems(inSection: 0) > index else { return }
		collectionView.performBatchUpdates(nil, completion: nil)
		collectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .left, animated: animated)
	}
	
	func showSlide(model: SlideModel, modelsCount: Int, modelIndex: Int) {
		//TODO:Fix later visibleCells
		if let cell = collectionView.visibleCells.first as? StoryCell {
			cell.slideView.backgroundColor = model.color
			cell.slideView.image = model.image
			var objects: [ProgressModel] = []
			for index in 0...modelsCount {
				var state: ProgressState
				if index < modelIndex {
					state = .watched
				} else if index ==  modelIndex {
					state = .inProgress
				} else {
					state = .notWatched
				}
				objects.append(ProgressModel(modelsCount: modelsCount, progressState: state))
			}
			let collectionSectionData = CollectionSectionData(objects: objects)
			cell.progressView.collectionViewAdapter.updateData(with: [collectionSectionData])
		}
	}
	
	func resumeAnimation() {
		self.view.layer.resume()
	}
	
	func pauseAnimation() {
		self.view.layer.pause()
	}
}

extension FullScreenViewController {
	
}

extension FullScreenViewController: FullScreenCollectionViewAdapterOutput {
	func storyCellDidTapOnLeftSide() {
		presenter.storyCellDidTapOnLeftSide()
	}
	
	func storyCellDidTapOnRightSide() {
		presenter.storyCellDidTapOnRightSide()
	}
	
	func storyCellTouchesBegan() {
		presenter.storyCellTouchesBegan()
	}
	
	func storyCellTouchesCancelled() {
		presenter.storyCellTouchesCancelled()
	}
	
	func storyCellDidTouchesEnded() {
		presenter.storyCellDidTouchesEnded()
	}
	
	func didScroll() {
		presenter.collectionViewDidScroll(contentSize: self.collectionView.contentSize, contentOffset: self.collectionView.contentOffset)
	}
	
	func didEndScrollingAnimation() {
		presenter.didEndScrollingAnimation()
	}
	
	func didEndDecelerating() {
		if let visibleIndexPath = collectionView.indexPathsForVisibleItems.first {
			presenter.collectionViewDidEndDecelerating(visibleIndexPath: visibleIndexPath)
		}
	}
	
	func closeButtonDidTap() {
		presenter.closeButtonDidTap()
	}
}
