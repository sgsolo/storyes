import UIKit

public protocol YStoriesManagerInput {
    var caruselViewController: UIViewController? { get }
    func loadStories()
}

public protocol YStoriesManagerOutput {
    func storiesDidLoad(_ isSuccess: Bool, error: Error?)
    func needShowFullScreen(_ fullScreen: FullScreenViewController, from frame: CGRect)
    func fullScreenDidTapOnCloseButton(atStoryWith frame: CGRect)
    func fullScreenStoriesDidEnd(atStoryWith frame: CGRect)
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
	
    private let storiesManagerOutput: YStoriesManagerOutput
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
        storiesManagerOutput.fullScreenDidTapOnCloseButton(atStoryWith: frame)
    }
    
    public func fullScreenStoriesDidEnd(storyIndex: Int) {
        self.carosuelModule?.input.scrollTo(storyIndex: storyIndex)
        let frame = self.carosuelModule?.input.getStoryFrame(at: storyIndex) ?? CGRect.zero
        storiesManagerOutput.fullScreenStoriesDidEnd(atStoryWith: frame)
    }
}

extension YStoriesManager {
    public func loadStories() {
        storiesService.getStories(success: { [weak self] _ in
            self?.storiesManagerOutput.storiesDidLoad(true, error: nil)
        }) { [weak self] error in
            self?.storiesManagerOutput.storiesDidLoad(false, error: error)
        }
    }
}

extension YStoriesManager: CarouselPreviewPresentrerOutput {
    public func didSelectStory(at index: Int, frame: CGRect) {
        let fullScreenViewController = FullScreenViewController()
        fullScreenModule = FullScreenAssembly.setup(fullScreenViewController, storiesService: storiesService, delegate: self)
        fullScreenModule?.setSelectedStory(index: index)
        storiesManagerOutput.needShowFullScreen(fullScreenViewController, from: frame)
    }
}
