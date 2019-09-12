class KPCarouselViewController: CarouselPreviewViewController {
    
    override lazy var loadingView: UIView? = {
        let v = LoadingView()
        return v
    }()
    override lazy var backgroundView: UIView? = {
        return GradientView()
    }()
    
    override var titleAttributes: [NSAttributedStringKey: Any] {
        return [
            NSAttributedString.Key.font: UIFont.kinopoiskFont(ofSize: 20, weight: .bold),
            NSAttributedString.Key.foregroundColor: UIColor.black,
            NSAttributedString.Key.paragraphStyle: paragraph(),
        ]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showLoadingView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let loadingView = loadingView as? LoadingView else {
            return
        }
        loadingView.startAnimation()
        Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { [weak self] _ in
            UIView.animate(withDuration: 0.3, animations: {
                loadingView.alpha = 0.0
                self?.carouselPreview.alpha = 1.0
            }, completion: { _ in
                loadingView.removeFromSuperview()
            })
        }
    }
    
    private func paragraph() -> NSMutableParagraphStyle {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .left
        paragraph.minimumLineHeight = 24
        return paragraph
    }
}

class GradientView: UIView {
    override class var layerClass: AnyClass {
        return BackgroundGradient.self
    }
}

class BackgroundGradient: CAGradientLayer {
    override init() {
        super.init()
        colors = [UIColor.white.cgColor, UIColor.lightGrayGradient.cgColor]
        locations = [0.0, 1.0]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class LoadingView: UIView {
    var config: CarouselPreviewConfiguration!
    private var _maskView: MaskView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.lightGrayGradient
    }
    
    override func didMoveToSuperview() {
        guard superview == nil else {
            return
        }
        self.mask = nil
        _maskView = nil
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startAnimation() {
        let animateLayer = AnimateGradient()
        let animGradientHeight: CGFloat = 80.0
        let animGradWidth = (2.0 * bounds.height * bounds.height).squareRoot() + animGradientHeight
        let frame = CGRect(
            x: 0,
            y: 0,
            width: animGradWidth,
            height: animGradientHeight
        )
        animateLayer.frame = frame
        let sqr = sqrt(animGradientHeight)
        let xDelta = (sqr + sqr / 4).squareRoot()
        animateLayer.anchorPoint = CGPoint(x: 0, y: 0)
        animateLayer.position = CGPoint(x: -(animGradWidth + xDelta), y: bounds.maxY)
        let rotation = CGAffineTransform(rotationAngle: CGFloat(Float.pi / -4.0))
        animateLayer.setAffineTransform(rotation)
        layer.addSublayer(animateLayer)
        
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 1
        animation.fromValue = animateLayer.position
        let finalX = bounds.maxX
        animation.toValue = CGPoint(x: finalX, y: animateLayer.position.y)
        animation.repeatCount = .infinity
        animateLayer.add(animation, forKey: nil)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if config.carouselWidth != bounds.width || self.mask == nil {
            config.carouselWidth = bounds.width
            config.cellsSpacing = 16
            config.visibleWidthOfPartialCell = 10
            config.sectionInset.left = 16
            config.cellApectRatio = .heightToWidth(1.5)
            _maskView = MaskView(conf: config)
            _maskView.frame = bounds
            self.mask = _maskView
        }
    }
}

class AnimateGradient: CAGradientLayer {
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

class MaskView: UIView {
    var conf: CarouselPreviewConfiguration
    var cellSize: CGSize
    
    init(conf: CarouselPreviewConfiguration) {
        self.conf = conf
        cellSize = CarouselPreviewSizeCalculator.cellSize(carouselConfiguration: conf)
        super.init(frame: .zero)
        clearsContextBeforeDrawing = false
        backgroundColor = .clear
        isOpaque = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
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
        
        var startX = conf.sectionInset.left
        for _ in 0...conf.numberOfVisibleCells {
            drawRoundedRectFrom(xCoordinate: startX)
            startX += conf.cellsSpacing + cellSize.width
        }
    }
}
