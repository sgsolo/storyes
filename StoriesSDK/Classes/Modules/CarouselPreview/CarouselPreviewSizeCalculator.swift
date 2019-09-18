public struct CarouselPreviewSizeCalculator {
    static func cellSize(
        forWidth width: CGFloat,
        carouselConfiguration config:
        CarouselConfiguration
    ) -> CGSize {
        let cellsSpacing = config.cellsSpacing
        let sectionInset = config.sectionInset.left
        var numberOfVisibleSpacing = config.numberOfVisibleCells - 1
        if config.visibleWidthOfPartialCell > 0 {
            numberOfVisibleSpacing += 1
        }
        let allVisibleCellsWidthWithoutSpacings =
            width - sectionInset - config.visibleWidthOfPartialCell - (cellsSpacing * CGFloat(numberOfVisibleSpacing))
        let cellWidth = (allVisibleCellsWidthWithoutSpacings / CGFloat(config.numberOfVisibleCells)).rounded()
        var cellHeight: CGFloat = 0.0
        switch config.cellApectRatio {
        case .heightToWidth(let ratio):
            cellHeight = cellWidth * ratio
        case .widthToHeight(let ratio):
            cellHeight = cellWidth / ratio
        }
        return CGSize(
            width: cellWidth,
            height: cellHeight.rounded()
        )
    }
    
    static func collectionViewHeight(
        forWidth width: CGFloat,
        carouselConfiguration config: CarouselConfiguration
    ) -> CGFloat {
        let cellSize = self.cellSize(
            forWidth: width,
            carouselConfiguration: config
        )
        return cellSize.height + config.sectionInset.bottom
    }
    
    public static func carouselHeight(
        forWidth width: CGFloat,
        targetApp: SupportedApp
    ) -> CGFloat {
        let config = CarouselConfigurationFactory.configForApp(targetApp)
        let carouselHeight = self.cellSize(
            forWidth: width,
            carouselConfiguration: config
        ).height
        return carouselHeight + config.sectionInset.bottom + config.titleBottomSpacing + config.titleFontSize
    }
}
