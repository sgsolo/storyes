class StoriePreviewCell: UICollectionViewCell, RegistrableComponent {
    
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    
    var borderWidth: CGFloat {
        return 0.0
    }
    
    var borderCornerRadius: CGFloat {
        return 0.0
    }
    
    var imageCornerRadius: CGFloat {
        return 0.0
    }
    
    func imageOverlayView() -> UIView {
        return UIView()
    }
    
    var imageViewFrameSpacing: CGFloat {
        return 0.0
    }
    
    var titleLabelIndent: CGFloat {
        return 0.0
    }
    
    var titleStringAttributes: [NSAttributedStringKey: Any] {
        return [:]
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.borderWidth = borderWidth
        contentView.layer.cornerRadius = borderCornerRadius
        configureImageView()
        configureTitleLabel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureImageView() {
        func configureImageOverlayView() {
            let imageOverlayView = self.imageOverlayView()
            imageView.addSubview(imageOverlayView)
            imageOverlayView.leftAnchor.constraint(equalTo: imageView.leftAnchor).isActive = true
            imageOverlayView.topAnchor.constraint(equalTo: imageView.topAnchor).isActive = true
            imageOverlayView.rightAnchor.constraint(equalTo: imageView.rightAnchor).isActive = true
            imageOverlayView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor).isActive = true
            imageOverlayView.layer.cornerRadius = imageCornerRadius
        }
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)
        imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: imageViewFrameSpacing).isActive = true
        imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: imageViewFrameSpacing).isActive = true
        contentView.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: imageViewFrameSpacing).isActive = true
        contentView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: imageViewFrameSpacing).isActive = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = imageCornerRadius
        imageView.clipsToBounds = true
        configureImageOverlayView()
    }
    
    private func configureTitleLabel() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        titleLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: titleLabelIndent).isActive = true
        contentView.rightAnchor.constraint(equalTo: titleLabel.rightAnchor, constant: titleLabelIndent).isActive = true
        contentView.bottomAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: titleLabelIndent).isActive = true
        titleLabel.backgroundColor = .clear
        titleLabel.numberOfLines = 0
    }
}

extension StoriePreviewCell: ConfigurableComponent {
    func configure(with object: Any) {
        guard let object = object as? StoriePreviewModel else {
            return
        }
        titleLabel.attributedText = NSAttributedString(string: object.title.string, attributes: titleStringAttributes)
        imageView.image = object.image
        if object.isViewed {
            contentView.layer.borderColor = YStoriesManager.uiStyle.viewedStoryBorderColor.cgColor
        } else {
            contentView.layer.borderColor = YStoriesManager.uiStyle.nonViewedStoryBorderColor.cgColor
        }
    }
}
