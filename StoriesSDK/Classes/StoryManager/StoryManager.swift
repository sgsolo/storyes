import UIKit

public protocol YStoriesManagerInput {
    var caruselViewController: UIViewController? { get }
    func loadStories()
}

public protocol YStoriesManagerOutput: class {
    func storiesDidLoad(_ isSuccess: Bool, error: Error?)
    func needShowFullScreen(_ fullScreen: FullScreenViewController, from frame: CGRect)
    func fullScreenDidTapOnCloseButton(atStoryWith frame: CGRect)
    func fullScreenStoriesDidEnd(atStoryWith frame: CGRect)
	
	func playPlayerIfNeeded()
	func stopPlayerIfNeeded()
}

extension YStoriesManagerOutput {
	func playPlayerIfNeeded() {}
	func stopPlayerIfNeeded() {}
}

public enum SupportedApp: String {
    case music
    case kinopoisk
}

public class YStoriesManager: YStoriesManagerInput {
	
	static var targetApp: SupportedApp = .music
	public static var needUseMockData = false
	
    public var caruselViewController: UIViewController?
    private var carosuelModule: CarouselPreviewModule?
    private var fullScreenModule: FullScreenModuleInput?
	
    private let user: String
    private let experiments: Dictionary<String, Any>
    weak private var storiesManagerOutput: YStoriesManagerOutput?
    private let storiesService: StoriesServiceInput = StoriesService.shared
    
    //TODO: добавить тему
    public init(targetApp: SupportedApp, user: String, experiments: Dictionary<String, Any> /*тема*/, storiesManagerOutput: YStoriesManagerOutput) {
        YStoriesManager.targetApp = targetApp
        self.user = user
        self.experiments = experiments
        self.storiesManagerOutput = storiesManagerOutput
        UIFont.loadAllFonts
        makeCaruselViewController()
    }
    
    func makeCaruselViewController() {
        let config = CarouselPreviewConfiguration(carouselWidth: UIScreen.main.bounds.width)
        self.carosuelModule = CarouselPreviewAssembly.setup(withConfig: config, delegate: self)
        caruselViewController = self.carosuelModule?.view
    }
}

extension YStoriesManager: FullScreenModuleOutput {
    public func fullScreenDidTapOnCloseButton(storyIndex: Int) {
        self.carosuelModule?.input.scrollTo(storyIndex: storyIndex)
        let frame = self.carosuelModule?.input.getStoryFrame(at: storyIndex) ?? CGRect.zero
        storiesManagerOutput?.fullScreenDidTapOnCloseButton(atStoryWith: frame)
    }
    
    public func fullScreenStoriesDidEnd(storyIndex: Int) {
        self.carosuelModule?.input.scrollTo(storyIndex: storyIndex)
        let frame = self.carosuelModule?.input.getStoryFrame(at: storyIndex) ?? CGRect.zero
        storiesManagerOutput?.fullScreenStoriesDidEnd(atStoryWith: frame)
    }
	
	public func didShowStoryWithImage() {
		storiesManagerOutput?.playPlayerIfNeeded()
	}
	
	public func didShowStoryWithVideoOrTrack() {
		storiesManagerOutput?.stopPlayerIfNeeded()
	}
}

extension YStoriesManager {
    public func loadStories() {
        storiesService.getStories(success: { [weak self] _ in
            self?.storiesManagerOutput?.storiesDidLoad(true, error: nil)
        }) { [weak self] error in
            self?.storiesManagerOutput?.storiesDidLoad(false, error: error)
        }
    }
}

extension YStoriesManager: CarouselPreviewPresentrerOutput {
    public func didSelectStory(at index: Int, frame: CGRect) {
        let fullScreenViewController = FullScreenViewController()
        fullScreenModule = FullScreenAssembly.setup(fullScreenViewController, storiesService: storiesService, delegate: self)
        fullScreenModule?.setSelectedStory(index: index)
        storiesManagerOutput?.needShowFullScreen(fullScreenViewController, from: frame)
    }
}
