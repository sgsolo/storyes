class CarouselLoadingView: UIView {
    private static let flickerGradiendHeight: CGFloat = 80.0
    private let flickerGradiendLayer = FlickerGradient()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.mask = CarouselLoadingPlaceholderView()
        flickerGradiendLayer.anchorPoint = CGPoint(x: 0, y: 0)
        backgroundColor = UIColor.lightGrayGradient
        layer.addSublayer(flickerGradiendLayer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func removeFromSuperview() {
        flickerGradiendLayer.removeAllAnimations()
        super.removeFromSuperview()
    }
    
    deinit {
        print("deinit CarouselLoadingView")
    }
    
    func startAnimation() {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 1
        animation.fromValue = flickerGradiendLayer.position
        let finalX = bounds.maxX
        animation.toValue = CGPoint(x: finalX, y: flickerGradiendLayer.position.y)
        animation.repeatCount = .infinity
        flickerGradiendLayer.add(animation, forKey: nil)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.mask?.frame = bounds
        flickerGradiendLayer.setAffineTransform(CGAffineTransform.identity)
        flickerGradiendLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        let height = CarouselLoadingView.flickerGradiendHeight
        let animGradWidth = (2.0 * bounds.height * bounds.height).squareRoot() + height
        let frame = CGRect(
            x: 0,
            y: 0,
            width: animGradWidth,
            height: height
        )
        flickerGradiendLayer.frame = frame
        
        let sqr = sqrt(height)
        let xDelta = (sqr + sqr / 4).squareRoot()
        flickerGradiendLayer.anchorPoint = CGPoint(x: 0, y: 0)
        flickerGradiendLayer.position = CGPoint(x: -(animGradWidth + xDelta), y: bounds.maxY)
        let rotation = CGAffineTransform(rotationAngle: CGFloat(Float.pi / -4.0))
        flickerGradiendLayer.setAffineTransform(rotation)
    }
}

private class FlickerGradient: CAGradientLayer {
    override init() {
        super.init()
        commonInit()
    }
    
    override init(layer: Any) {
        super.init(layer: layer)
        commonInit()
    }
    
    func commonInit() {
        colors = [
            UIColor.lightGrayGradient.cgColor,
            UIColor.grayGradient.cgColor,
            UIColor.grayGradient.cgColor,
            UIColor.lightGrayGradient.cgColor
        ]
        locations = [0.0, 0.37, 0.63, 1.0]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
