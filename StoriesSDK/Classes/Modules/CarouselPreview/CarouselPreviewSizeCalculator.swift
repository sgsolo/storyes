struct CarouselPreviewSizeCalculator {
    static func cellSize(carouselConfiguration config: CarouselPreviewConfiguration) -> CGSize {
        let cellsSpacing = config.cellsSpacing
        let sectionInset = config.sectionInset.left
        var numberOfVisibleSpacing = config.numberOfVisibleCells - 1
        if config.visibleWidthOfPartialCell > 0 {
            numberOfVisibleSpacing += 1
        }
        let allVisibleCellsWidthWithoutSpacings = config.carouselWidth - sectionInset - config.visibleWidthOfPartialCell - (cellsSpacing * CGFloat(numberOfVisibleSpacing))
        let cellWidth = (allVisibleCellsWidthWithoutSpacings / CGFloat(config.numberOfVisibleCells)).rounded()
        var cellHeight: CGFloat = 0.0
        switch config.cellApectRatio {
        case .heightToWidth(let ratio):
            cellHeight = cellWidth * ratio
        case .widthToHeight(let ratio):
            cellHeight = cellWidth / ratio
        }
        return CGSize(width: cellWidth, height: cellHeight.rounded())
    }
}
