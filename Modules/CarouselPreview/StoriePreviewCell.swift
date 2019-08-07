class StoriePreviewCell: UICollectionViewCell, RegistrableComponent {
    static let imageCornerRadius: CGFloat = 4
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .lightGray
        layer.borderWidth = 2
        layer.cornerRadius = 7
        configureImageView()
        configureTitleLabel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureImageView() {
        func configureImageOverlayView() {
            let imageOverlayView = UIView()
            imageOverlayView.backgroundColor = .black
            imageOverlayView.alpha = 0.4
            imageOverlayView.translatesAutoresizingMaskIntoConstraints = false
            imageView.addSubview(imageOverlayView)
            imageOverlayView.leftAnchor.constraint(equalTo: imageView.leftAnchor).isActive = true
            imageOverlayView.topAnchor.constraint(equalTo: imageView.topAnchor).isActive = true
            imageOverlayView.rightAnchor.constraint(equalTo: imageView.rightAnchor).isActive = true
            imageOverlayView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor).isActive = true
            imageOverlayView.layer.cornerRadius = StoriePreviewCell.imageCornerRadius
        }
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)
        imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4).isActive = true
        imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4).isActive = true
        contentView.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 4).isActive = true
        contentView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 4).isActive = true
        imageView.contentMode = .center
        imageView.layer.cornerRadius = StoriePreviewCell.imageCornerRadius
        imageView.clipsToBounds = true
        configureImageOverlayView()
    }
    
    private func configureTitleLabel() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        titleLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16).isActive = true
        contentView.rightAnchor.constraint(equalTo: titleLabel.rightAnchor, constant: 16).isActive = true
        contentView.bottomAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16).isActive = true
        titleLabel.backgroundColor = .clear
        titleLabel.numberOfLines = 0
    }
}

extension StoriePreviewCell: ConfigurableComponent {
    func configure(with object: Any) {
        guard let object = object as? StoriePreviewModel else {
            return
        }
        titleLabel.attributedText = object.title
        imageView.image = object.image
        #warning("Encapsulate color in enum")
        if object.isViewed {
            layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).cgColor
        } else {
            layer.borderColor = UIColor(red: 0, green: 0.47, blue: 0.8, alpha: 1).cgColor
        }
    }
}
