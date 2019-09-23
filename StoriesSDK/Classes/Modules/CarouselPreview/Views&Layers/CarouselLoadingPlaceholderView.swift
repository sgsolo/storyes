class CarouselLoadingPlaceholderView: UIView {
    private var config = KPCarouselPlaceholderConfiguration()
    
    override var isOpaque: Bool {
        get { return false }
        set { print("\(self): Setting isOpaque property is ignored and always is false")}
    }
    
    override func draw(_ rect: CGRect) {
        let cellSize = CarouselPreviewSizeCalculator.cellSize(
            forWidth: rect.width,
            carouselConfiguration: config
        )
        
        func drawRoundedRectFrom(xCoordinate: CGFloat) {
            let frame = CGRect(
                x: xCoordinate,
                y: 5.0,
                width: cellSize.width,
                height: cellSize.height
            )
            let path = UIBezierPath(
                roundedRect: frame,
                cornerRadius: 7
            )
            path.fill()
        }
        
        var startX = config.sectionInset.left
        for _ in 0...config.numberOfVisibleCells {
            drawRoundedRectFrom(xCoordinate: startX)
            startX += config.cellsSpacing + cellSize.width
        }
    }
}
