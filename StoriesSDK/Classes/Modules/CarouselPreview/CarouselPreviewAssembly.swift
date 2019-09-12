//#warning("Struct just for CarouselUITesting")
public struct CarouselPreviewModule {
    public let view: CarouselPreviewViewController
    public let input: CarouselPreviewPresentrerInput
}

public struct CarouselPreviewAssembly {
    public static func setup(for targetApp: SupportedApp, delegate: CarouselPreviewPresentrerOutput) -> CarouselPreviewModule {
        let config = CarouselConfigurationFactory.configForApp(YStoriesManager.targetApp)
        let viewController: CarouselPreviewViewController!
        switch targetApp {
        case .kinopoisk:
            viewController = KPCarouselViewController(with: config)
        case .music:
            viewController = MusicCarouselPreview(with: config)
        }
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
