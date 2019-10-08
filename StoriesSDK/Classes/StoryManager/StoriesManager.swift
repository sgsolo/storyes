import UIKit

public protocol YStoriesManagerInput {
    var caruselViewController: UIViewController? { get }
    func loadStories()
    func colorThemeDidChange(_ toColorTheme: YColorTheme)
}

public protocol YStoriesManagerOutput: class {
    func storiesDidLoad(_ isSuccess: Bool, error: Error?)
    func needShowFullScreen(_ fullScreen: FullScreenViewController)
    func fullScreenDidTapOnCloseButton(fullScreen: FullScreenViewController)
    func fullScreenStoriesDidEnd(fullScreen: FullScreenViewController)
	
	func playPlayerIfNeeded()
	func stopPlayerIfNeeded()
	func openUrlIfPossible(url: URL, fullScreen: FullScreenViewController)
}

extension YStoriesManagerOutput {
	func playPlayerIfNeeded() {}
	func stopPlayerIfNeeded() {}
}

public enum SupportedApp: String {
    case music
    case kinopoisk
}

public class YStoriesManager: NSObject, YStoriesManagerInput {
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
	private weak var fullScreenViewController: FullScreenViewController?
    private var fullScreenModule: FullScreenModuleInput?
	private var fullScreenStartFrame: CGRect?
	private var fullScreenEndFrame: CGRect?
	
    private weak var storiesManagerOutput: YStoriesManagerOutput?
    private let storiesService: StoriesServiceInput
    
	public convenience init(storiesManagerOutput: YStoriesManagerOutput) {
		self.init(storiesManagerOutput: storiesManagerOutput, storiesService: StoriesService.shared)
    }
	
	init(storiesManagerOutput: YStoriesManagerOutput, storiesService: StoriesServiceInput) {
		self.storiesManagerOutput = storiesManagerOutput
		self.storiesService = storiesService
		UIFont.loadAllFonts
		super.init()
		makeCarouselViewController(for: YStoriesManager.targetApp)
	}
    
    private func makeCarouselViewController(for targetApp: SupportedApp) {
        self.carosuelModule = CarouselPreviewAssembly.setup(for: targetApp, delegate: self)
        caruselViewController = self.carosuelModule?.view
    }
}

extension YStoriesManager: FullScreenModuleOutput {
    public func fullScreenDidTapOnCloseButton(storyIndex: Int) {
        calculateFullScreenEndFrame(storyIndex: storyIndex)
		if let fullScreenViewController = fullScreenViewController {
			storiesManagerOutput?.fullScreenDidTapOnCloseButton(fullScreen: fullScreenViewController)
		}
    }
    
    public func fullScreenStoriesDidEnd(storyIndex: Int) {
        calculateFullScreenEndFrame(storyIndex: storyIndex)
		if let fullScreenViewController = fullScreenViewController {
			storiesManagerOutput?.fullScreenStoriesDidEnd(fullScreen: fullScreenViewController)
		}
    }
	
	public func didShowStoryWithImage() {
		storiesManagerOutput?.playPlayerIfNeeded()
	}
	
	public func didShowStoryWithVideoOrTrack() {
		storiesManagerOutput?.stopPlayerIfNeeded()
	}
	
	public func didTapOnButton(url: URL, storyIndex: Int) {
		calculateFullScreenEndFrame(storyIndex: storyIndex)
		if let fullScreenViewController = fullScreenViewController {
			storiesManagerOutput?.openUrlIfPossible(url: url, fullScreen: fullScreenViewController)
		}
	}
	
	private func calculateFullScreenEndFrame(storyIndex: Int) {
		self.carosuelModule?.input.scrollTo(storyIndex: storyIndex)
		let frame = self.carosuelModule?.input.getStoryFrame(at: storyIndex)
		self.fullScreenEndFrame = frame
	}
}

extension YStoriesManager {
    public func loadStories() {
		storiesService.getStories { [weak self] result in
			switch result {
			case .success(let stories):
				self?.storiesManagerOutput?.storiesDidLoad(true, error: nil)
				self?.carosuelModule?.input.storiesDidLoad(stories: stories)
			case .failure(let error):
				self?.storiesManagerOutput?.storiesDidLoad(false, error: error)
			}
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
		fullScreenViewController.transitioningDelegate = self
		self.fullScreenViewController = fullScreenViewController
        fullScreenModule = FullScreenAssembly.setup(fullScreenViewController, storiesService: storiesService, delegate: self)
        fullScreenModule?.setSelectedStory(index: index)
		self.fullScreenStartFrame = frame
        storiesManagerOutput?.needShowFullScreen(fullScreenViewController)
    }
}

extension YStoriesManager: UIViewControllerTransitioningDelegate {
	public func animationController(forPresented presented: UIViewController,
							 presenting: UIViewController,
							 source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return FullScreenPresentAnimation(startFrame: self.fullScreenStartFrame ?? .zero)
	}
	
	public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return FullScreenDismissedAnimation(endFrame: self.fullScreenEndFrame ?? .zero)
	}
}
