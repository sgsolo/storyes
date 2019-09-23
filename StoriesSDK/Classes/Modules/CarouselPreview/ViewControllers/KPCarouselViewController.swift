class KPCarouselViewController: StoriesCarouselViewController {
    
    override lazy var loadingView: UIView? = {
        let view = CarouselLoadingView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    override lazy var backgroundView: UIView? = {
        return GradientView()
    }()
    
    override var titleAttributes: [NSAttributedStringKey: Any] {
        return [
            .font: UIFont.kinopoiskFont(ofSize: 20, weight: .bold),
            .foregroundColor: UIColor.black,
            .paragraphStyle: paragraph(),
        ]
    }
    
    override func showData(_ data: [CollectionSectionData]) {
        super.showData(data)
        hideLoadingView()
    }
    
    func hideLoadingView() {
        carouselPreview.isHidden = false
        UIView.animate(withDuration: 0.3, animations: {
            self.loadingView?.alpha = 0.0
            self.carouselPreview.alpha = 1.0
        }, completion: { _ in
            self.loadingView = nil
        })
    }
    
    override func showLoadingView() {
        guard let loadingView = loadingView as? CarouselLoadingView else {
            carouselPreview.alpha = 1.0
            carouselPreview.isHidden = false
            return
        }
        carouselPreview.alpha = 0.0
        carouselPreview.isHidden = true
        view.addSubview(loadingView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        loadingView?.frame = carouselPreview.frame
    }
    
    private func paragraph() -> NSMutableParagraphStyle {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .left
        paragraph.minimumLineHeight = 24
        return paragraph
    }
}
