public struct CarouselPreviewConfiguration {
    public var carouselWidth: CGFloat
    public var cellsSpacing: CGFloat = 16
    public var sectionInset = UIEdgeInsets(top: 0.0, left: 16.0, bottom: 0.0, right: 16.0)
    public var numberOfVisibleCells = 2
    public var visibleWidthOfPartialCell: CGFloat = 16
    public var cellHeightToWidthAspectRatio: CGFloat = 1.5
    
    public init(carouselWidth: CGFloat) {
        self.carouselWidth = carouselWidth
    }
}
