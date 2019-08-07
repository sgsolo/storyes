import UIKit

enum ProgressState {
	case notWatched
	case inProgress
	case watched
}

struct ProgressModel {
	var modelsCount: Int
	var progressState: ProgressState
}

class ProgressView: UIView {
	var collectionViewAdapter: ProgressCollectionViewAdapterInput = ProgressCollectionViewAdapter()
	
	private var collectionView: UICollectionView = {
		let layout = UICollectionViewFlowLayout()
		layout.minimumInteritemSpacing = 0
		layout.minimumLineSpacing = 0
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
		return collectionView
	}()
	static let leftRightInset: CGFloat = 16
	static let topBottomInset: CGFloat = 0
	static let cellSpacing: CGFloat = 8
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		configureCollectionView()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func configureCollectionView() {
		self.addSubview(collectionView)
		collectionView.backgroundColor = .clear
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		collectionView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
		collectionView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
		collectionView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
		collectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
		collectionView.contentInset = UIEdgeInsets(top: ProgressView.topBottomInset, left: ProgressView.leftRightInset, bottom: ProgressView.topBottomInset, right: ProgressView.leftRightInset)
		
		collectionViewAdapter.collectionView = collectionView
	}
}
