import UIKit

class ProgressCell: UICollectionViewCell {
	
	private let cornerRadiusValue: CGFloat = 2
	
	private let translucentView = UIView()
	private let progressView = UIView()
	
	var progressViewWidthConstraint: NSLayoutConstraint!
	var progressState: ProgressState?
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		configureTranslucentView()
		configureProgressView()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func configureProgressView() {
		self.addSubview(progressView)
		progressView.layer.cornerRadius = cornerRadiusValue
		progressView.backgroundColor = .white
		progressView.translatesAutoresizingMaskIntoConstraints = false
		progressView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
		progressView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
		progressView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
		progressViewWidthConstraint = progressView.widthAnchor.constraint(equalToConstant: 0)
		progressViewWidthConstraint.isActive = true
	}
	
	private func configureTranslucentView() {
		self.addSubview(translucentView)
		translucentView.layer.cornerRadius = cornerRadiusValue
		translucentView.backgroundColor = UIColor(white: 1, alpha: 0.4)
		translucentView.translatesAutoresizingMaskIntoConstraints = false
		translucentView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
		translucentView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
		translucentView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
		translucentView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
	}
}

extension ProgressCell: RegistrableComponent {}

extension ProgressCell: CollectionViewItemsSizeProvider {
	static func size(for item: Any?, collectionViewSize: CGSize) -> CGSize {
		if let item = item as? ProgressModel {
			let spacing: CGFloat = ProgressView.cellSpacing
			let leftRightInsets: CGFloat = ProgressView.leftRightInset
			let width = (collectionViewSize.width - (spacing * CGFloat(item.modelsCount - 1)) - leftRightInsets * 2) / CGFloat(item.modelsCount)
			return CGSize(width: width, height: collectionViewSize.height)
		} else {
			return .zero
		}
	}
}

extension ProgressCell: ConfigurableComponent {
	func configure(with object: Any) {
		print("configure ProgressCell")
		if let model = object as? ProgressModel {
			progressState = model.progressState
		}
	}
}

extension ProgressCell: DisplayableComponent {
	func prepareForDisplay(with object: Any) {
		if let progressState = progressState {
			switch progressState {
			case .notWatched:
				self.progressViewWidthConstraint.constant = 0
			case .inProgress:
				self.progressViewWidthConstraint.constant = 0
				self.layoutIfNeeded()
				self.progressViewWidthConstraint.constant = self.bounds.width
				//TODO: брать длительность из модели
				UIView.animate(withDuration: 6, delay: 0, options: .curveLinear, animations: {
					self.layoutIfNeeded()
				})
			case .watched:
				self.progressViewWidthConstraint.constant = self.bounds.width
			}
		}
	}
}
