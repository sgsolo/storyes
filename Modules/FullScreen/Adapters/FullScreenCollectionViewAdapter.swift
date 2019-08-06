import Foundation

protocol FullScreenCollectionViewAdapterInput: BaseCollectionViewAdpaterInput {
	
}

protocol FullScreenCollectionViewAdapterOutput: BaseCollectionViewAdapterOutput {
	func storyCellDidTapOnLeftSide()
	func storyCellDidTapOnRightSide()
	func storyCellTouchesBegan()
	func storyCellTouchesCancelled()
	func storyCellDidTouchesEnded()
	
	func closeButtonDidTap()
}

final class FullScreenCollectionViewAdapter: BaseCollectionViewAdapter, FullScreenCollectionViewAdapterInput {
	
	private var fullScreenOutput: FullScreenCollectionViewAdapterOutput? {
		return output as? FullScreenCollectionViewAdapterOutput
	}
	
	override init() {
		super.init()		
		self.cellClasses = [StoryCell.self]
	}
}

extension FullScreenCollectionViewAdapter {
	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = super.collectionView(collectionView, cellForItemAt: indexPath)
		(cell as? StoryCell)?.delegate = self
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {

	}
	
}

extension FullScreenCollectionViewAdapter: StoryCellDelegate {
	func storyCellDidTapOnLeftSide() {
		fullScreenOutput?.storyCellDidTapOnLeftSide()
	}
	
	func storyCellDidTapOnRightSide() {
		fullScreenOutput?.storyCellDidTapOnRightSide()
	}
	
	func storyCellTouchesBegan() {
		fullScreenOutput?.storyCellTouchesBegan()
	}
	
	func storyCellTouchesCancelled() {
		fullScreenOutput?.storyCellTouchesCancelled()
	}
	
	func storyCellDidTouchesEnded() {
		fullScreenOutput?.storyCellDidTouchesEnded()
	}
	
	func closeButtonDidTap() {
		fullScreenOutput?.closeButtonDidTap()
	}
}
