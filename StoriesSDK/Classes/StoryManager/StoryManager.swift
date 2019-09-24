import UIKit

public protocol YStoriesManagerInput {
    var caruselViewController: UIViewController? { get }
    func loadStories()
    func colorThemeDidChange(_ toColorTheme: YColorTheme)
}

public protocol YStoriesManagerOutput: class {
    func storiesDidLoad(_ isSuccess: Bool, error: Error?)
    func needShowFullScreen(_ fullScreen: FullScreenViewController, from frame: CGRect)
    func fullScreenDidTapOnCloseButton(atStoryWith frame: CGRect)
    func fullScreenStoriesDidEnd(atStoryWith frame: CGRect)
	
	func playPlayerIfNeeded()
	func stopPlayerIfNeeded()
	func openUrlIfPossible(url: URL, atStoryWith frame: CGRect)
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
    public static var needUseMockData = false
    
    public static func configure(for targetApp: SupportedApp, with colorTheme: YColorTheme) {
        self.targetApp = targetApp
        self.uiStyle = YUIStyleService(
            with: colorTheme,
            for: targetApp
        )
    }
    
    public static func setColorTheme(_ colorTheme: YColorTheme) {
        self.uiStyle = YUIStyleService(
            with: colorTheme,
            for: self.targetApp
        )
    }
    
    private(set) static var targetApp: SupportedApp = .music
    private(set) static var uiStyle: YUIStyle = YMusicUIStyleLight()
    
    public var caruselViewController: UIViewController?
    private var carosuelModule: CarouselPreviewModule?
    private var fullScreenModule: FullScreenModuleInput?
	
    weak private var storiesManagerOutput: YStoriesManagerOutput?
    private let storiesService: StoriesServiceInput = StoriesService.shared
    
    public init(storiesManagerOutput: YStoriesManagerOutput) {
        self.storiesManagerOutput = storiesManagerOutput
        UIFont.loadAllFonts
        makeCarouselViewController(for: YStoriesManager.targetApp)
    }
    
    func makeCarouselViewController(for targetApp: SupportedApp) {
        self.carosuelModule = CarouselPreviewAssembly.setup(for: targetApp, delegate: self)
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
	
	public func didTapOnButton(url: URL, storyIndex: Int) {
		self.carosuelModule?.input.scrollTo(storyIndex: storyIndex)
		let frame = self.carosuelModule?.input.getStoryFrame(at: storyIndex) ?? CGRect.zero
		storiesManagerOutput?.openUrlIfPossible(url: url, atStoryWith: frame)
	}
}

extension YStoriesManager {
    public func loadStories() {
        storiesService.getStories(success: { [weak self] _ in
            self?.storiesManagerOutput?.storiesDidLoad(true, error: nil)
            guard let stories = self?.storiesService.stories else {
                return
            }
            self?.carosuelModule?.input.storiesDidLoad(stories: stories)
        }) { [weak self] error in
            self?.storiesManagerOutput?.storiesDidLoad(false, error: error)
        }
    }
    
    public func colorThemeDidChange(_ toColorTheme: YColorTheme) {
        YStoriesManager.uiStyle = YUIStyleService(
            with: toColorTheme,
            for: YStoriesManager.targetApp
        )
        NotificationCenter.default.post(
            name: YStoriesNotification.colorThemeDidChange,
            object: toColorTheme
        )
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
