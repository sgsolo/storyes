protocol ProgressCollectionViewAdapterInput: BaseCollectionViewAdpaterInput {
	
}

protocol ProgressCollectionViewAdapterOutput: BaseCollectionViewAdapterOutput {

}
class ProgressCollectionViewAdapter: BaseCollectionViewAdapter, ProgressCollectionViewAdapterInput {
	override init() {
		super.init()
		self.cellClasses = [ProgressCell.self]
	}
}

extension ProgressCollectionViewAdapter {
	func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		if let cell = cell as? ProgressCell, let progressState = cell.progressState {
			switch progressState {
			case .notWatched:
				cell.progressViewWidthConstraint.constant = 0
			case .inProgress:
				cell.progressViewWidthConstraint.constant = 0
				cell.layoutIfNeeded()
				cell.progressViewWidthConstraint.constant = cell.bounds.width
				//TODO: брать длительность из модели
				UIView.animate(withDuration: 6, delay: 0, options: .curveLinear, animations: {
					cell.layoutIfNeeded()
				})
			case .watched:
				cell.progressViewWidthConstraint.constant = cell.bounds.width
			}
		}
	}
	
}
