class MusicCarouselCell: StoriePreviewCell {
    
    override var borderWidth: CGFloat {
        return 2.0
    }
    
    override var borderCornerRadius: CGFloat {
        return 7.0
    }
    
    override var imageViewFrameSpacing: CGFloat {
        return 4.0
    }
    
    override var imageCornerRadius: CGFloat {
        return 4.0
    }
    
    override var titleLabelIndent: CGFloat {
        return 16.0
    }
    
    override func imageOverlayView() -> UIView {
        let imageOverlayView = UIView()
        imageOverlayView.backgroundColor = .black
        imageOverlayView.alpha = 0.4
        return imageOverlayView
    }
    
    override var titleStringAttributes: [NSAttributedStringKey: Any] {
        return [
            .font: UIFont.systemFont(ofSize: 16, weight: .medium),
            .foregroundColor: UIColor.white,
            .kern: -0.15,
            .paragraphStyle: paragraph(),
            .shadow: shadow()
        ]
    }
    
    private func shadow() -> NSShadow {
        let shadow = NSShadow()
        shadow.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25)
        shadow.shadowOffset = CGSize(width: 0, height: 1)
        shadow.shadowBlurRadius = 2
        return shadow
    }
    
    private func paragraph() -> NSMutableParagraphStyle {
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = 3
        return paragraph
    }
}
