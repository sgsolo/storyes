struct KPCarouselPlaceholderConfiguration: CarouselConfiguration {
    private static let kpCarouselConfig = KPCarouselConfiguration()
    let titleBottomSpacing: CGFloat = kpCarouselConfig.titleBottomSpacing
    let titleFontSize: CGFloat = kpCarouselConfig.titleFontSize
    let targetApp: SupportedApp = kpCarouselConfig.targetApp
    let numberOfVisibleCells = kpCarouselConfig.numberOfVisibleCells
    let cellsSpacing: CGFloat = 16.0
    let sectionInset = UIEdgeInsets(top: 0.0, left: 16.0, bottom: 0.0, right: 16.0)
    let visibleWidthOfPartialCell: CGFloat = 10.0
    let cellApectRatio = StoryCellAspectRatio.heightToWidth(1.5)
}
