class GradientView: UIView {
    override class var layerClass: AnyClass {
        return BackgroundGradient.self
    }
}

private class BackgroundGradient: CAGradientLayer {
    override init() {
        super.init()
        colors = [UIColor.white.cgColor, UIColor.lightGrayGradient.cgColor]
        locations = [0.0, 1.0]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
