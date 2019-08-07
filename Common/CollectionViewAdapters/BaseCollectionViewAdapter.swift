import UIKit

struct CollectionSectionData {
	var objects: [Any]
    var header: Any?
    var footer: Any?
    
    init(objects: [Any], header: Any? = nil, footer: Any? = nil) {
		self.objects = objects
        self.header = header
        self.footer = footer
    }
}

protocol BaseCollectionViewAdpaterInput: class {
    var collectionView: UICollectionView? { get set }
    
    func updateData(with models: [CollectionSectionData])
}

protocol BaseCollectionViewAdapterOutput: class {
    func didSelectCollectionCell(at indexPath: IndexPath)
	func didScroll()
    func didEndScrollingAnimation()
    func didEndDragging(willDecelerate: Bool)
    func didEndDecelerating()
}

extension BaseCollectionViewAdapterOutput {
    func didSelectCollectionCell(at indexPath: IndexPath) {}
	func didScroll() {}
    func didEndScrollingAnimation() {}
	func willBeginDecelerating() {}
    func didEndDragging(willDecelerate: Bool) {}
    func didEndDecelerating() {}
}

/// Base adapter for collection views
///
class BaseCollectionViewAdapter: NSObject, BaseCollectionViewAdpaterInput {
    
    weak var output: BaseCollectionViewAdapterOutput?
    
    var collectionView: UICollectionView? {
        didSet {
            self.prepareCollectionView()
        }
    }
    
    var collectionSections: [CollectionSectionData] = []
    
    /// Classes for used cells
    ///
    /// Should be setted before `collectionView`
    var cellClasses: [RegistrableComponent.Type] = []
    
    /// Classes for supplementary views
    ///
    /// Should be setted before `collectionView`
    var supplementaryViewsClasses: [RegistrableSupplementaryViewComponent.Type] = []
    
    func prepareCollectionView() {
        self.registerCells()
        self.registerSupplementaryViews()
        
        self.collectionView?.dataSource = self
        self.collectionView?.delegate = self
    }
    
    func registerCells() {
        self.cellClasses.forEach { (type) in
            switch type.registrableSource {
            case .class:
                self.collectionView?.register(type as? AnyClass, forCellWithReuseIdentifier: type.identifier)
            }
        }
    }
    
    func registerSupplementaryViews() {
        self.supplementaryViewsClasses.forEach { (type) in
            switch type.registrableSource {
            case .class:
                self.collectionView?.register(type as? AnyClass, forSupplementaryViewOfKind: type.kind, withReuseIdentifier: type.identifier)
            }
        }
    }
    
    /// Provide cell class for cell model
    ///
    /// override to return appropriate class (`self.cellClasses.first` by default)
    func cellClass(for model: Any) -> RegistrableComponent.Type? {
        return self.cellClasses.first
    }
    
    func supplementaryViewClass(for indexPath: IndexPath, kind: String) -> RegistrableSupplementaryViewComponent.Type? {
        return self.supplementaryViewsClasses.first(where: { $0.kind == kind })
    }
    
    // MARK: BaseCollectionViewAdpaterInput
    
    func updateData(with models: [CollectionSectionData]) {
        self.collectionSections = models
        
        self.collectionView?.reloadData()
    }
    
}

extension BaseCollectionViewAdapter: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.collectionSections.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.collectionSections[section].objects.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = self.collectionSections[indexPath.section].objects[indexPath.row]
        
        guard let cellClass = self.cellClass(for: item) else { return UICollectionViewCell() }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellClass.identifier, for: indexPath)
        (cell as? ConfigurableComponent)?.configure(with: item)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let viewClass = self.supplementaryViewClass(for: indexPath, kind: kind) else {
            return UICollectionReusableView()
        }
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: viewClass.identifier, for: indexPath)
        
		if kind == UICollectionElementKindSectionHeader,
            let object = self.collectionSections[indexPath.section].header {
            (view as? ConfigurableComponent)?.configure(with: object)
		} else if kind == UICollectionElementKindSectionFooter,
            let object = self.collectionSections[indexPath.section].footer {
            (view as? ConfigurableComponent)?.configure(with: object)
        }
        
        return view
    }
}

extension BaseCollectionViewAdapter: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.output?.didSelectCollectionCell(at: indexPath)
    }
	
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		self.output?.didScroll()
	}
	
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        self.output?.didEndScrollingAnimation()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.output?.didEndDragging(willDecelerate: decelerate)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.output?.didEndDecelerating()
    }
	
	func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		let item = self.collectionSections[indexPath.section].objects[indexPath.row]
		(cell as? DisplayableComponent)?.prepareForDisplay(with: item)
	}
}

extension BaseCollectionViewAdapter: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let item = self.collectionSections[indexPath.section].objects[indexPath.row]
        
        guard let cellClass = self.cellClass(for: item) as? CollectionViewItemsSizeProvider.Type else { return .zero }
        
        return cellClass.size(for: item, collectionViewSize: collectionView.bounds.size)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
		guard let viewClass = self.supplementaryViewClass(for: IndexPath(item: 0, section: section), kind: UICollectionElementKindSectionFooter) as? CollectionViewItemsSizeProvider.Type  else {
            return .zero
        }
        
        return viewClass.size(for: self.collectionSections[section].footer, collectionViewSize: collectionView.bounds.size)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
		guard let viewClass = self.supplementaryViewClass(for: IndexPath(item: 0, section: section), kind: UICollectionElementKindSectionHeader) as? CollectionViewItemsSizeProvider.Type else {
            return .zero
        }
        
        return viewClass.size(for: self.collectionSections[section].header, collectionViewSize: collectionView.bounds.size)
    }
}
