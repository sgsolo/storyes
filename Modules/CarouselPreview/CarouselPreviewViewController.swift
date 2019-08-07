protocol CarouselPreviewInput: class {
    func showData(_ data: [StoriePreviewModel])
}

public protocol CarouselPreviewOutput: class {
    func loadView()
}

public class CarouselPreviewViewController: UIViewController {
    // MARK: - Properties
    var presenter: CarouselPreviewOutput!
    var collectionViewAdapter: CarouselPreviewCollectionViewAdapterInput!
    
    private var carouselPreviewAdapter: CarouselPreviewCollectionViewAdapter!
    private var configuration: CarouselPreviewConfiguration
    private let titleLabel = UILabel()
    private var carouselPreview: UICollectionView!
    
    // MARK: - Lifecycle & overriden
    init(with configuration: CarouselPreviewConfiguration) {
        self.configuration = configuration
        super.init(nibName: nil, bundle: nil)
        createCollectionViewWithConfiguration(configuration)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        configureTitleLabel()
        configureCarouselPreview()
        presenter.loadView()
    }
}

// MARK: - UI creation & configuration
extension CarouselPreviewViewController {
    private func createCollectionViewWithConfiguration(_ config: CarouselPreviewConfiguration) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = config.cellsSpacing
        layout.sectionInset = config.sectionInset
        carouselPreview = UICollectionView(frame: .zero, collectionViewLayout: layout)
    }
    
    private func configureTitleLabel() {
        titleLabel.font = UIFont.systemFont(ofSize: 18.0, weight: .bold)
        titleLabel.backgroundColor = .clear
        titleLabel.textColor = .black
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 1
        view.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        titleLabel.text = "Истории"
    }
    
    private func configureCarouselPreview() {
        carouselPreview.showsHorizontalScrollIndicator = false
        carouselPreview.backgroundColor = .clear
        carouselPreview.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(carouselPreview)
        carouselPreview.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        carouselPreview.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        carouselPreview.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16).isActive = true
        let cellHeight = CarouselPreviewSizeCalculator.cellSize(carouselConfiguration: configuration).height
        carouselPreview.heightAnchor.constraint(equalToConstant: cellHeight).isActive = true
    }
}

extension CarouselPreviewViewController: CarouselPreviewInput {
    func showData(_ data: [StoriePreviewModel]) {
        collectionViewAdapter.collectionView = carouselPreview
        let sectionData = CollectionSectionData(objects: data)
        collectionViewAdapter.updateData(with: [sectionData])
    }
}

extension CarouselPreviewViewController: CarouselPreviewOutput {

}
