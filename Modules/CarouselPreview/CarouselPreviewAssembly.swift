#warning("Struct just for CarouselUITesting")
public struct CarouselPreviewModule {
    public let view: CarouselPreviewViewController
    public let input: CarouselPreviewOutput
}

public struct CarouselPreviewAssembly {
    public static func setup(withConfig config: CarouselPreviewConfiguration) -> CarouselPreviewModule {
        let viewController = CarouselPreviewViewController(with: config)
        let presenter = CarouselPreviewPresentrer()
        let adapter = CarouselPreviewCollectionViewAdapter(with: config)
        viewController.presenter = presenter
        viewController.collectionViewAdapter = adapter
        presenter.view = viewController
        return CarouselPreviewModule(view: viewController, input: presenter)
    }
}
