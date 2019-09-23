protocol CarouselPreviewCollectionViewAdapterInput: BaseCollectionViewAdpaterInput {
    
}
protocol CarouselPreviewCollectionViewAdapterOutput: BaseCollectionViewAdapterOutput {
    
}

final class CarouselCollectionViewAdapter: BaseCollectionViewAdapter, CarouselPreviewCollectionViewAdapterInput {
    private var config: CarouselConfiguration
    
    init(with configuration: CarouselConfiguration) {
        config = configuration
        super.init()
        switch configuration.targetApp {
        case .kinopoisk:
            self.cellClasses = [KinopoiskCarouselCell.self]
        case .music:
            self.cellClasses = [MusicCarouselCell.self]
        }
    }
    
    override func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CarouselPreviewSizeCalculator.cellSize(
            forWidth: collectionView.bounds.width,
            carouselConfiguration: config
        )
    }
}

