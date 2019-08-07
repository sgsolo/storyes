import UIKit

class PagedSliderFlowLayout: UICollectionViewFlowLayout {
	override class var layoutAttributesClass: AnyClass { return AnimatedCollectionViewLayoutAttributes.self }
	
	var inset: CGFloat
	
	init(inset: CGFloat) {
		self.inset = inset
		super.init()
		scrollDirection = .horizontal
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
		guard let collectionView = collectionView else { return CGPoint(x: 0, y: 0) }
		let scannerFrame = CGRect(x: proposedContentOffset.x, y: collectionView.bounds.origin.y, width: collectionView.bounds.width, height: collectionView.bounds.height)
		let layoutAttributes = super.layoutAttributesForElements(in: scannerFrame)
		let proposedXCoordWithInsets = proposedContentOffset.x + inset + minimumLineSpacing / 2
		var offsetCorrection = proposedContentOffset.x == 0 ? 0 : CGFloat.greatestFiniteMagnitude
		layoutAttributes?.forEach({ attribute in
			guard attribute.representedElementCategory == .cell else { return }
			let discardableScrollingElementsFrame = collectionView.contentOffset.x + collectionView.frame.size.width / 2
			if (attribute.center.x < discardableScrollingElementsFrame && velocity.x > 0) || (attribute.center.x > discardableScrollingElementsFrame && velocity.x < 0) {
				return
			}
			if abs(attribute.frame.origin.x - proposedXCoordWithInsets) < abs(offsetCorrection) {
				offsetCorrection = attribute.frame.origin.x - proposedXCoordWithInsets
			}
		})
		return CGPoint(x: proposedContentOffset.x + offsetCorrection, y: collectionView.bounds.origin.y)
	}
	
	override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
		guard let attributes = super.layoutAttributesForElements(in: rect) else { return nil }
		return attributes.compactMap { $0 as? AnimatedCollectionViewLayoutAttributes }.map { self.transformLayoutAttributes($0) }
	}
	
	override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
		return true
	}
	
	private func transformLayoutAttributes(_ attributes: AnimatedCollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
		guard let collectionView = self.collectionView else { return attributes }
		var attributes = attributes
		let distance: CGFloat
		let itemOffset: CGFloat
		if scrollDirection == .horizontal {
			distance = collectionView.frame.width
			itemOffset = attributes.center.x - collectionView.contentOffset.x
		} else {
			distance = collectionView.frame.height
			itemOffset = attributes.center.y - collectionView.contentOffset.y
		}
		attributes.middleOffset = itemOffset / distance - 0.5
		attributes = animate(attributes: attributes)
		return attributes
	}
	
	private func animate(attributes: AnimatedCollectionViewLayoutAttributes) -> AnimatedCollectionViewLayoutAttributes {
		let position = attributes.middleOffset
		let scaleFactor = 1 - (abs(position) * 0.2)
		if abs(position) >= 1 {
			attributes.transform = .identity
		} else {
			attributes.transform = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
		}
		attributes.zIndex = attributes.indexPath.row
		return attributes
	}
}

class AnimatedCollectionViewLayoutAttributes: UICollectionViewLayoutAttributes {
	var middleOffset: CGFloat = 0
}
