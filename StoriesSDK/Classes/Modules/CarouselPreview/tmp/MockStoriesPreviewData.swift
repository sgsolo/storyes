class MockStoriesPreviewData {
    static let font = UIFont.systemFont(ofSize: 16, weight: .medium)

    static func storiesPreviewData() -> [StoriePreviewModel] {
        let bundle = Bundle(for: self)
        let obj0 = StoriePreviewModel(
            title: attrString("Новый Two Door Cinema Club"),
            image: UIImage(named: "Preview0.jpeg", in: bundle, compatibleWith: nil) ?? UIImage(),
            isViewed: false)
        let obj1 = StoriePreviewModel(
            title: attrString("Что послушать летом?"),
            image: UIImage(named: "Preview1.jpeg", in: bundle, compatibleWith: nil) ?? UIImage(),
            isViewed: false)
        let obj2 = StoriePreviewModel(
            title: attrString("Горячие новинки месяца"),
            image: UIImage(named: "Preview2.jpeg", in: bundle, compatibleWith: nil) ?? UIImage(),
            isViewed: true)
        let obj3 = StoriePreviewModel(
            title: attrString("Все альбомы Tool на Музыке"),
            image: UIImage(named: "Preview3.jpeg", in: bundle, compatibleWith: nil) ?? UIImage(),
            isViewed: true)
        let obj4 = StoriePreviewModel(
            title: attrString("Thomas Mraz вернулся"),
            image: UIImage(named: "Preview4.jpeg", in: bundle, compatibleWith: nil) ?? UIImage(),
            isViewed: true)
        return [obj0,obj1,obj2,obj3,obj4,obj4,obj4,obj4,obj4]
    }
    
    static func attrString(_ str: String) -> NSAttributedString {
        return NSAttributedString(
            string: str,
            attributes: [
                NSAttributedString.Key.font: font,
                NSAttributedString.Key.foregroundColor: UIColor.white,
                NSAttributedString.Key.kern: -0.15,
                NSAttributedString.Key.paragraphStyle: paragraph(),
                NSAttributedString.Key.shadow: shadow()
            ]
        )
    }
    
    static func shadow() -> NSShadow {
        let shadow = NSShadow()
        shadow.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25)
        shadow.shadowOffset = CGSize(width: 0, height: 1)
        shadow.shadowBlurRadius = 2
        return shadow
    }
    
    static func paragraph() -> NSMutableParagraphStyle {
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = 3
        return paragraph
    }
}
