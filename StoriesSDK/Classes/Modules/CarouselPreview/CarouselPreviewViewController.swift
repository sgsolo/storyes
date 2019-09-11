import UIKit

protocol CarouselPreviewInput: class {
    func showData(_ data: [CollectionSectionData])
	func scrollTo(storyIndex: Int)
	func getStoryFrame(at storyIndex: Int) -> CGRect
}

public protocol CarouselPreviewOutput: class {
    func viewDidLoad()
	func didSelectCollectionCell(at indexPath: IndexPath, frame: CGRect)
}

public class CarouselPreviewViewController: UIViewController {
    // MARK: - Properties
    var presenter: CarouselPreviewOutput!
    var collectionViewAdapter: CarouselPreviewCollectionViewAdapterInput!
    
    private var carouselPreviewAdapter: CarouselCollectionViewAdapter!
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
        presenter.viewDidLoad()
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
        carouselPreview.delaysContentTouches = false
    }
    
    private func configureTitleLabel() {
        titleLabel.font = .systemFont(ofSize: 18.0, weight: .bold)
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
        collectionViewAdapter.collectionView = carouselPreview
        carouselPreview.showsHorizontalScrollIndicator = false
        carouselPreview.backgroundColor = .clear
        carouselPreview.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(carouselPreview)
        carouselPreview.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        carouselPreview.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        carouselPreview.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16).isActive = true
    }
    
    public override func updateViewConstraints() {
        configuration.carouselWidth = view.bounds.width
        let cellHeight = CarouselPreviewSizeCalculator.cellSize(carouselConfiguration: configuration).height
        carouselPreview.heightAnchor.constraint(equalToConstant: cellHeight).isActive = true
        super.updateViewConstraints()
    }
}

extension CarouselPreviewViewController: CarouselPreviewInput {    
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

extension CarouselPreviewViewController: CarouselPreviewCollectionViewAdapterOutput {
	public func didSelectCollectionCell(at indexPath: IndexPath) {
		if let cell = self.carouselPreview.cellForItem(at: indexPath) {
			let frame = cell.convert(cell.bounds, to: nil)
			presenter.didSelectCollectionCell(at: indexPath, frame: frame)
		}
	}
}
