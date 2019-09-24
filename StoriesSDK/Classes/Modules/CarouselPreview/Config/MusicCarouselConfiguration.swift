struct MusicCarouselConfiguration: CarouselConfiguration {
    let targetApp: SupportedApp = .music
    let cellsSpacing: CGFloat = 16.0
    let sectionInset = UIEdgeInsets(top: 0.0, left: 16.0, bottom: 0.0, right: 16.0)
    let numberOfVisibleCells = 2
    let visibleWidthOfPartialCell: CGFloat = 16.0
    let cellApectRatio = StoryCellAspectRatio.heightToWidth(1.5)
    let titleBottomSpacing: CGFloat = 16
    let titleFontSize: CGFloat = 24.0
}
