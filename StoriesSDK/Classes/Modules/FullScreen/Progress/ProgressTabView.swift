import UIKit

enum ProgressState {
	case notWatched
	case inProgress
	case watched
}

class ProgressTabView: UIView {
	static let leftRightInset: CGFloat = 16
	static let topBottomInset: CGFloat = 0
	static let cellSpacing: CGFloat = 8
	
	var progressViewWidthConstraint: NSLayoutConstraint?
	var progressState: ProgressState = .notWatched
	
	private let cornerRadiusValue: CGFloat = 2
	private let translucentView = UIView()
	private let progressView = UIView()
	
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
		progressViewWidthConstraint?.isActive = true
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
