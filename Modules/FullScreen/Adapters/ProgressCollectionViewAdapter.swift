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
