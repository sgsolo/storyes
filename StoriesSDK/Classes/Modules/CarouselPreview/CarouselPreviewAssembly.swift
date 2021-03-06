struct CarouselPreviewModule {
    let view: StoriesCarouselViewController
    let input: CarouselPreviewPresentrerInput
}

struct CarouselPreviewAssembly {
    static func setup(for targetApp: SupportedApp, delegate: CarouselPreviewPresentrerOutput) -> CarouselPreviewModule {
        let config = CarouselConfigurationFactory.configForApp(YStoriesManager.targetApp)
        let viewController: StoriesCarouselViewController!
        switch targetApp {
        case .kinopoisk:
            viewController = KPCarouselViewController(with: config)
        case .music:
            viewController = MusicCarouselViewController(with: config)
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
