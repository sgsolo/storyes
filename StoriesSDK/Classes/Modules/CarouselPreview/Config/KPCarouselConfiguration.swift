struct KPCarouselConfiguration: CarouselConfiguration {
    let targetApp: SupportedApp = .kinopoisk
    let cellsSpacing: CGFloat = 6.0
    let sectionInset = UIEdgeInsets(top: 0.0, left: 11.0, bottom: 19.0, right: 11.0)
    let numberOfVisibleCells = 2
    let visibleWidthOfPartialCell: CGFloat = 16.0
    let cellApectRatio = StoryCellAspectRatio.widthToHeight(0.68)
    let titleBottomSpacing: CGFloat = 11
    let titleFontSize: CGFloat = 24.0
}
