import CoreGraphics

protocol CollectionViewItemsSizeProvider {
    static func size(for item: Any?, collectionViewSize: CGSize) -> CGSize
}
