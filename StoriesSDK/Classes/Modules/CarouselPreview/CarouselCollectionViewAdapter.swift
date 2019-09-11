protocol CarouselPreviewCollectionViewAdapterInput: BaseCollectionViewAdpaterInput {
    
}
protocol CarouselPreviewCollectionViewAdapterOutput: BaseCollectionViewAdapterOutput {
    
}

final class CarouselCollectionViewAdapter: BaseCollectionViewAdapter, CarouselPreviewCollectionViewAdapterInput {
    private var collectionViewConfiguration: CarouselPreviewConfiguration
    private var cellSize = CGSize.zero
    
    init(with configuration: CarouselPreviewConfiguration) {
        collectionViewConfiguration = configuration
        super.init()
        switch configuration.targetApp {
        case .kinopoisk:
            self.cellClasses = [KinopoiskCarouselCell.self]
        case .music:
            self.cellClasses = [MusicCarouselCell.self]
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionViewConfiguration.carouselWidth != collectionView.bounds.width {
            collectionViewConfiguration.carouselWidth = collectionView.bounds.width
            cellSize = CarouselPreviewSizeCalculator.cellSize(carouselConfiguration: collectionViewConfiguration)
        }
        return cellSize
    }
}

