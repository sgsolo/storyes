class KinopoiskCarouselCell: StoriePreviewCell {
    
    override var borderWidth: CGFloat {
        return 2.0
    }
    
    override var borderCornerRadius: CGFloat {
        return 13.0
    }
    
    override var imageViewFrameSpacing: CGFloat {
        return 5.0
    }
    
    override var imageCornerRadius: CGFloat {
        return 8.0
    }
    
    override var titleLabelIndent: CGFloat {
        return 19.0
    }
    
    override var viewedBorderColor: UIColor {
        return UIColor.defaultCarouselBorderViewed
    }
    
    override var nonviewedBorderColor: UIColor {
        return UIColor.kpCarouselBorder
    }
    
    override func imageOverlayView() -> UIView {
        let imageOverlayView = UIView()
        imageOverlayView.clipsToBounds = true
        imageOverlayView.translatesAutoresizingMaskIntoConstraints = false
        imageOverlayView.backgroundColor = .clear
        let gradient = CAGradientLayer()
        let topColor = UIColor.init(white: 0, alpha: 0)
        let bottomColor = UIColor.init(white: 0, alpha: 0.5)
        gradient.colors = [topColor.cgColor, bottomColor.cgColor]
        gradient.locations = [0.0, 1.0]
        gradient.frame = self.bounds
        imageOverlayView.layer.addSublayer(gradient)
        return imageOverlayView
    }
    
    override var titleStringAttributes: [NSAttributedStringKey: Any] {
        return [
            NSAttributedString.Key.font: UIFont.kinopoiskFont(ofSize: 16, weight: .bold),
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.paragraphStyle: paragraph()
        ]
    }
    
    private func paragraph() -> NSMutableParagraphStyle {
        let paragraph = NSMutableParagraphStyle()
        paragraph.minimumLineHeight = 18.9
        return paragraph
    }
}
