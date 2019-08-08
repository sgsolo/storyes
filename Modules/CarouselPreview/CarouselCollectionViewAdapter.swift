protocol CarouselPreviewCollectionViewAdapterInput: BaseCollectionViewAdpaterInput {
    
}
protocol CarouselPreviewCollectionViewAdapterOutput: BaseCollectionViewAdapterOutput {
    
}

final class CarouselCollectionViewAdapter: BaseCollectionViewAdapter, CarouselPreviewCollectionViewAdapterInput {
    private let cellSize: CGSize
    
    init(with configuration: CarouselPreviewConfiguration) {
        cellSize = CarouselPreviewSizeCalculator.cellSize(carouselConfiguration: configuration)
        super.init()
        self.cellClasses = [StoriePreviewCell.self]
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cellSize
    }
}

