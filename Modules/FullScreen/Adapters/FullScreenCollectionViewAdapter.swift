//
//  FullScreenCollectionViewAdapter.swift
//  Stories_iOS
//
//  Created by Григорий Соловьев on 29/07/2019.
//

import Foundation

protocol FullScreenCollectionViewAdapterInput: BaseCollectionViewAdpaterInput {
	
}

protocol FullScreenCollectionViewAdapterOutput: BaseCollectionViewAdapterOutput {
	
}

final class FullScreenCollectionViewAdapter:
	BaseCollectionViewAdapter,
FullScreenCollectionViewAdapterInput {
	override init() {
		super.init()		
		self.cellClasses = [UICollectionViewCell.self]
	}
}
//TODO: for test, remove after
extension UICollectionViewCell: RegistrableComponent {}
//TODO: for test, remove after
extension UICollectionViewCell: CollectionViewItemsSizeProvider {
	static func size(for item: Any?, collectionViewSize: CGSize) -> CGSize {
		return CGSize(width: collectionViewSize.width, height: collectionViewSize.height / 2.0)
	}
}
//TODO: for test, remove after
extension UICollectionViewCell: ConfigurableComponent {
	func configure(with object: Any) {
		let doubleValue = CGFloat(Int.random(in: 0...255)) / 255.0
		self.backgroundColor = UIColor(red: doubleValue, green: doubleValue, blue: doubleValue, alpha: 1)
	}
}
