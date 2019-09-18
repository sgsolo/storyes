import UIKit

protocol CarouselViewInput: class {
    func showData(_ data: [CollectionSectionData])
	func scrollTo(storyIndex: Int)
	func getStoryFrame(at storyIndex: Int) -> CGRect
}

public protocol CarouselViewOutput: class {
    func viewDidLoad()
	func didSelectCollectionCell(at indexPath: IndexPath, frame: CGRect)
}

public class StoriesCarouselViewController: UIViewController {
    // MARK: - Properties
    var presenter: CarouselViewOutput!
    var collectionViewAdapter: CarouselPreviewCollectionViewAdapterInput!
    
    private var carouselPreviewAdapter: CarouselCollectionViewAdapter!
    private var configuration: CarouselConfiguration
    private(set) var titleLabel = UILabel()
    private(set) var carouselPreview: UICollectionView!
    
    // MARK: - Properties for overriding in subclass
    lazy var backgroundView: UIView? = {
        return nil
    }()
    
    lazy var loadingView: UIView? = {
        return nil
    }()
    
    var titleAttributes: [NSAttributedStringKey: Any] {
        return [:]
    }
    
    // MARK: - Lifecycle & overriden
    init(with configuration: CarouselConfiguration) {
        self.configuration = configuration
        super.init(nibName: nil, bundle: nil)
        createCollectionViewWithConfiguration(configuration)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        addBackgroundView()
        configureTitleLabel()
        configureCarouselPreview()
        presenter.viewDidLoad()
    }
    
    private func addBackgroundView() {
        guard let bgView = backgroundView else {
            return
        }
        bgView.frame = view.bounds
        bgView.translatesAutoresizingMaskIntoConstraints = false
        bgView.autoresizingMask = UIView.AutoresizingMask(arrayLiteral: .flexibleHeight, .flexibleWidth)
        view.addSubview(bgView)
    }
    
    func showLoadingView() {
        carouselPreview.alpha = 0.0
        guard let loadingView = loadingView else {
            carouselPreview.isHidden = false
            return
        }
        view.addSubview(loadingView)
    }
}

// MARK: - UI creation & configuration
extension StoriesCarouselViewController {
    private func createCollectionViewWithConfiguration(_ config: CarouselConfiguration) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = config.cellsSpacing
        layout.sectionInset = config.sectionInset
        carouselPreview = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )
    }
    
    private func configureTitleLabel() {
        titleLabel.backgroundColor = .clear
        titleLabel.numberOfLines = 1
        view.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.topAnchor.constraint(
            equalTo: view.topAnchor
        ).isActive = true
        titleLabel.leadingAnchor.constraint(
            equalTo: view.leadingAnchor,
            constant: 16
        ).isActive = true
        view.trailingAnchor.constraint(
            equalTo: titleLabel.trailingAnchor,
            constant: 16
        ).isActive = true
        updateTitle()
    }
    
    func updateTitle() {
        titleLabel.attributedText = NSAttributedString(
            string: "Истории",
            attributes: titleAttributes
        )
    }
    
    private func configureCarouselPreview() {
        collectionViewAdapter.collectionView = carouselPreview
        carouselPreview.showsHorizontalScrollIndicator = false
        carouselPreview.backgroundColor = .clear
        carouselPreview.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(carouselPreview)
        carouselPreview.leadingAnchor.constraint(
            equalTo: view.leadingAnchor
        ).isActive = true
        carouselPreview.trailingAnchor.constraint(
            equalTo: view.trailingAnchor
        ).isActive = true
        carouselPreview.topAnchor.constraint(
            equalTo: titleLabel.bottomAnchor,
            constant: configuration.titleBottomSpacing
        ).isActive = true
    }
    
    public override func updateViewConstraints() {
        let height = CarouselPreviewSizeCalculator.collectionViewHeight(
            forWidth: view.bounds.width,
            carouselConfiguration: configuration
        )
        carouselPreview.heightAnchor.constraint(equalToConstant: height).isActive = true
        super.updateViewConstraints()
    }
}

extension StoriesCarouselViewController: CarouselViewInput {    
    func showData(_ data: [CollectionSectionData]) {
        collectionViewAdapter.updateData(with: data)
    }
	
	func scrollTo(storyIndex: Int) {
		guard carouselPreview.numberOfSections > 0, carouselPreview.numberOfItems(inSection: 0) > storyIndex else { return }
		//TODO: нужен ли скролл до зарывающейся ячейки истории?
//		carouselPreview.scrollToItem(at: IndexPath(item: storyIndex, section: 0), at: .centeredHorizontally, animated: false)
	}
	
	func getStoryFrame(at storyIndex: Int) -> CGRect {
		guard carouselPreview.numberOfSections > 0,
			carouselPreview.numberOfItems(inSection: 0) > storyIndex,
			let window = UIApplication.shared.delegate?.window else { return .zero }
		
		if let cell = carouselPreview.cellForItem(at: IndexPath(item: storyIndex, section: 0)) {
			return cell.convert(cell.bounds, to: window)
		} else if let visibleCell = carouselPreview.visibleCells.last {
			return visibleCell.convert(visibleCell.bounds, to: window)
		}
		return .zero
	}
}

extension StoriesCarouselViewController: CarouselPreviewCollectionViewAdapterOutput {
	public func didSelectCollectionCell(at indexPath: IndexPath) {
		if let cell = self.carouselPreview.cellForItem(at: indexPath) {
			let frame = cell.convert(cell.bounds, to: nil)
			presenter.didSelectCollectionCell(at: indexPath, frame: frame)
		}
	}
}
