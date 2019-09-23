class MusicCarouselViewController: StoriesCarouselViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(colorThemeDidChange),
            name: YStoriesNotification.colorThemeDidChange,
            object: nil
        )
    }
    
    @objc private func colorThemeDidChange() {
        updateTitle()
    }
    
    override var titleAttributes: [NSAttributedStringKey: Any] {
        return [
            .font: UIFont.systemFont(ofSize: 18.0, weight: .bold),
            .foregroundColor: YStoriesManager.uiStyle.storiesTitleColor,
            .paragraphStyle: paragraph(),
        ]
    }
    
    private func paragraph() -> NSMutableParagraphStyle {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        paragraph.minimumLineHeight = 24
        return paragraph
    }
}
