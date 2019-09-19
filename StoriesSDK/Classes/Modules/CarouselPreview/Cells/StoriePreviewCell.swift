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
            imageOverlayView.translatesAutoresizingMaskIntoConstraints = false
            imageView.addSubview(imageOverlayView)
            imageOverlayView.leadingAnchor.constraint(equalTo: imageView.leadingAnchor).isActive = true
            imageOverlayView.topAnchor.constraint(equalTo: imageView.topAnchor).isActive = true
            imageView.trailingAnchor.constraint(equalTo: imageOverlayView.trailingAnchor).isActive = true
            imageView.bottomAnchor.constraint(equalTo: imageOverlayView.bottomAnchor).isActive = true
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
        titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: titleLabelIndent).isActive = true
        contentView.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: titleLabelIndent).isActive = true
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
        titleLabel.attributedText = NSAttributedString(
            string: object.title,
            attributes: titleStringAttributes
        )
        imageView.image = object.image
        if object.isViewed {
            contentView.layer.borderColor = YStoriesManager.uiStyle.viewedStoryBorderColor.cgColor
        } else {
            contentView.layer.borderColor = YStoriesManager.uiStyle.nonViewedStoryBorderColor.cgColor
        }
    }
}
