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
    
    override func imageOverlayView() -> UIView {
        let imageOverlayView = UIView()
        imageOverlayView.clipsToBounds = true
        imageOverlayView.backgroundColor = .clear
        let gradient = CAGradientLayer()
        let topColor = UIColor(white: 0, alpha: 0)
        let bottomColor = UIColor(white: 0, alpha: 0.5)
        gradient.colors = [topColor.cgColor, bottomColor.cgColor]
        gradient.locations = [0.0, 1.0]
        gradient.frame = self.bounds
        imageOverlayView.layer.addSublayer(gradient)
        return imageOverlayView
    }
    
    override var titleStringAttributes: [NSAttributedStringKey: Any] {
        return [
            .font: UIFont.kinopoiskFont(ofSize: 16, weight: .bold),
            .foregroundColor: UIColor.white,
            .paragraphStyle: paragraph()
        ]
    }
    
    private func paragraph() -> NSMutableParagraphStyle {
        let paragraph = NSMutableParagraphStyle()
        paragraph.minimumLineHeight = 18.9
        return paragraph
    }
}
