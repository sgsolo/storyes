//#warning("Struct just for CarouselUITesting")
public struct CarouselPreviewModule {
    public let view: CarouselPreviewViewController
    public let input: CarouselPreviewPresentrerInput
}

public struct CarouselPreviewAssembly {
	public static func setup(withConfig config: CarouselPreviewConfiguration, delegate: CarouselPreviewPresentrerOutput) -> CarouselPreviewModule {
        let viewController = CarouselPreviewViewController(with: config)
        let presenter = CarouselPreviewPresentrer()
        let adapter = CarouselCollectionViewAdapter(with: config)
		adapter.output = viewController
		
        viewController.presenter = presenter
        viewController.collectionViewAdapter = adapter
        presenter.view = viewController
		presenter.output = delegate
        return CarouselPreviewModule(view: viewController, input: presenter)
    }
}
