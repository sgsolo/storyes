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
            NSAttributedString.Key.font: UIFont.kinopoiskFont(ofSize: 20, weight: .bold),
            NSAttributedString.Key.foregroundColor: UIColor.black,
            NSAttributedString.Key.paragraphStyle: paragraph(),
        ]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showLoadingView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        loadingView?.frame = carouselPreview.frame
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let loadingView = loadingView as? CarouselLoadingView else {
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
