import UIKit

protocol FullScreenViewInput: class {
}

protocol FullScreenViewOutput: class {
}

public final class FullScreenViewController: UIViewController {
	var presenter: FullScreenViewOutput!
	var collectionViewAdapter: FullScreenCollectionViewAdapterInput!
	
	private var collectionView: UICollectionView = {
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		return collectionView
	}()
	
	override public func loadView() {
		super.loadView()
		configureCollectionView()
	}
	
	func configureCollectionView() {
		self.view.addSubview(collectionView)
		collectionView.backgroundColor = .white
		collectionView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
		collectionView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
		collectionView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
		collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
		
		collectionViewAdapter.collectionView = collectionView
		let sectionData = CollectionSectionData(objects: [1, 2, 3, 4, 5])
		collectionViewAdapter.updateData(with: [sectionData])
	}
}

extension FullScreenViewController: FullScreenViewInput {
	
}
