import UIKit

public protocol YStoriesManagerInput {
	var caruselViewController: UIViewController! { get }
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
	
	public var caruselViewController: UIViewController!
	private var carosuelModule: CarouselPreviewModule!
	private var fullScreenModule: FullScreenModuleInput!
	
	private let currentApp: SupportedApp
	private let user: String
	private let experiments: Dictionary<String, Any>
	private let storiesManagerOutput: YStoriesManagerOutput
	private let storiesService: StoriesServiceInput = StoriesService()
	
	//TODO: добавить тему
	public init(currentApp: SupportedApp, user: String, experiments: Dictionary<String, Any> /*тема*/, storiesManagerOutput: YStoriesManagerOutput) {
		self.currentApp = currentApp
		self.user = user
		self.experiments = experiments
		self.storiesManagerOutput = storiesManagerOutput
		
		makeCaruselViewController()
	}
	
	func makeCaruselViewController() {
		let config = CarouselPreviewConfiguration(carouselWidth: UIScreen.main.bounds.width)
		self.carosuelModule = CarouselPreviewAssembly.setup(withConfig: config, delegate: self)
		caruselViewController = self.carosuelModule.view
	}
}

extension YStoriesManager: FullScreenModuleOutput {
	public func fullScreenDidTapOnCloseButton(storyIndex: Int) {
		self.carosuelModule.input.scrollTo(storyIndex: storyIndex)
		let frame = self.carosuelModule.input.getStoryFrame(at: storyIndex)
		storiesManagerOutput.fullScreenDidTapOnCloseButton(atStoryWith: frame)
	}
	
	public func fullScreenStoriesDidEnd(storyIndex: Int) {
		self.carosuelModule.input.scrollTo(storyIndex: storyIndex)
		let frame = self.carosuelModule.input.getStoryFrame(at: storyIndex)
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
		fullScreenModule.setSelectedStory(index: index)
		storiesManagerOutput.needShowFullScreen(fullScreenViewController, from: frame)
	}
}