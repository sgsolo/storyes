protocol CarouselConfiguration {
    var targetApp: SupportedApp { get }
    var cellsSpacing: CGFloat { get }
    var sectionInset: UIEdgeInsets { get }
    var numberOfVisibleCells: Int { get }
    var visibleWidthOfPartialCell: CGFloat { get }
    var cellApectRatio: StoryCellAspectRatio { get }
    var titleBottomSpacing: CGFloat { get }
    var titleFontSize: CGFloat { get }
}
