class KPCarouselViewController: CarouselPreviewViewController {
    override var loadingView: UIView? {
        return UIView()
    }
    
    override var backgroundView: UIView? {
        return GradientView()
    }
    
    override var titleAttributes: [NSAttributedStringKey: Any] {
        return [
            NSAttributedString.Key.font: UIFont.kinopoiskFont(ofSize: 20, weight: .bold),
            NSAttributedString.Key.foregroundColor: UIColor.black,
            NSAttributedString.Key.paragraphStyle: paragraph(),
        ]
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
