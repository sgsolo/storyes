class MusicCarouselPreview: CarouselPreviewViewController {
    override var titleAttributes: [NSAttributedStringKey: Any] {
        return [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18.0, weight: .bold),
            NSAttributedString.Key.foregroundColor: UIColor.black,
            NSAttributedString.Key.paragraphStyle: paragraph(),
        ]
    }
    
    private func paragraph() -> NSMutableParagraphStyle {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        paragraph.minimumLineHeight = 24
        return paragraph
    }
}
