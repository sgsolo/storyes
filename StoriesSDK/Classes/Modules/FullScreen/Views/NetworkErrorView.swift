
import UIKit

protocol NetworkErrorViewDelegate: class {
	func didTapRetryButton()
}

class NetworkErrorView: UIView {
	
	weak var delegate: NetworkErrorViewDelegate?
	
	private let titleLabel = UILabel()
	private let subtitleLabel = UILabel()
	private let retryButton = UIButton()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.backgroundColor = .black
		addListenButton()
		addSubtitleLabel()
		addTitleLabel()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
		if retryButton.frame.contains(point) {
			return retryButton
		}
		return nil
	}
	
	private func addListenButton() {
		self.addSubview(retryButton)
		retryButton.layer.cornerRadius = 4
		retryButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
		retryButton.setTitle("Обновить", for: .normal)
		retryButton.titleLabel?.font = .kinopoiskFont(ofSize: 15, weight: .medium)
		retryButton.setTitleColor(UIColor(red: 51/255.0, green: 51/255.0, blue: 51/255.0, alpha: 1), for: .normal)
		retryButton.backgroundColor = UIColor(red: 242/255.0, green: 242/255.0, blue: 242/255.0, alpha: 1)
		retryButton.addTarget(self, action: #selector(didTapRetryButton), for: .touchUpInside)
		
		retryButton.translatesAutoresizingMaskIntoConstraints = false
		retryButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
		retryButton.widthAnchor.constraint(equalToConstant: 118).isActive = true
		retryButton.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
		retryButton.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 16).isActive = true
	}
	
	private func addTitleLabel() {
		self.addSubview(titleLabel)
		titleLabel.text = "Отсутствует соединение"
		titleLabel.font = .kinopoiskFont(ofSize: 15, weight: .bold)
		titleLabel.textAlignment = .center
		titleLabel.textColor = .white
		
		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		titleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
		titleLabel.bottomAnchor.constraint(equalTo: self.subtitleLabel.topAnchor, constant: -8).isActive = true
	}
	
	private func addSubtitleLabel() {
		self.addSubview(subtitleLabel)
		subtitleLabel.numberOfLines = 0
		subtitleLabel.text = "Проверьте ваше соединение\nи попробуйте еще раз"
		subtitleLabel.font = .kinopoiskFont(ofSize: 13, weight: .regular)
		subtitleLabel.textAlignment = .center
		subtitleLabel.textColor = .white
		subtitleLabel.alpha = 0.6
		
		subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
		subtitleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
		subtitleLabel.bottomAnchor.constraint(equalTo: self.retryButton.topAnchor, constant: -16).isActive = true
	}
	
	@objc func didTapRetryButton(_ sender: UIButton) {
		delegate?.didTapRetryButton()
	}
}
