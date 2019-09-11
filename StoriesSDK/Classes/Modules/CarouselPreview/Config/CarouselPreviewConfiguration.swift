struct CarouselPreviewConfiguration {
    var targetApp: SupportedApp
    var cellsSpacing: CGFloat
    var sectionInset: UIEdgeInsets
    var numberOfVisibleCells: Int
    var visibleWidthOfPartialCell: CGFloat
    var cellApectRatio: AspectRatio
    var carouselWidth: CGFloat = 0.0
    
    init(targetApp: SupportedApp,
         cellsSpacing: CGFloat,
         sectionInset: UIEdgeInsets,
         numberOfVisibleCells: Int,
         visibleWidthOfPartialCell: CGFloat,
         cellApectRatio: AspectRatio
    ) {
        self.targetApp = targetApp
        self.cellsSpacing = cellsSpacing
        self.sectionInset = sectionInset
        self.numberOfVisibleCells = numberOfVisibleCells
        self.visibleWidthOfPartialCell = visibleWidthOfPartialCell
        self.cellApectRatio = cellApectRatio
    }
}
