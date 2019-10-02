import UIKit

protocol StoriesServiceInput: class {
    var stories: [StoryModel]? { get }
	var currentStoryIndex: StoryIndex { get set }
    func getStories(completion: @escaping (Result<[StoryModel], Error>) -> Void)
    func getData(_ slideModel: SlideModel, completion: @escaping (Result<SlideViewModel, Error>) -> Void)
	func prevStory() -> StoryModel?
	func nextStory() -> StoryModel?
	func preloadNextStory()
	func preloadPreviousStory()
	func preloadNextSlide()
}

struct StoryIndex {
    var storyIndex: Int = 0 {
        didSet {
            slideIndex = 0
        }
    }
    var slideIndex: Int = 0
}

class StoriesService: StoriesServiceInput {
	static let shared = StoriesService(apiClient: ApiClient())
	
	var currentStoryIndex = StoryIndex()
    var stories: [StoryModel]?
	
    private var storyesPredownloadQueue: [() -> Void] = []
    private var isDownloading = false
    private let apiClient: ApiClientInput
	
	init(apiClient: ApiClientInput) {
		self.apiClient = apiClient
	}
	
	func getStories(completion: @escaping (Result<[StoryModel], Error>) -> Void) {
		apiClient.getCarusel { result in
			switch result {
			case .success(let data):
				do {
					let stories = try JSONDecoder().decode(StoriesModel.self, from: data)
					self.stories = stories.stories
					completion(.success(stories.stories))
				}
				catch {
					print(error)
					completion(.failure(error))
				}
			case .failure(let error):
				print(error)
				completion(.failure(error))
			}
		}
    }
    
	func getData(_ url: URL, completion: @escaping (Result<URL, Error>) -> Void) {
		apiClient.getData(url, completion: completion)
    }
    
    func getData(_ slideModel: SlideModel, completion: @escaping (Result<SlideViewModel, Error>) -> Void) {
        var viewModel = SlideViewModel()
        viewModel.fillFromSlideModel(slideModel)
        let dispatchGroup = DispatchGroup()
        var networkError: Error?
		if let storageDir = slideModel.video?.storageDir, let videoUrl = URL(string: storageDir) {
            viewModel.type = .video
            dispatchGroup.enter()
			getData(videoUrl, completion: { result in
				switch result {
				case .success(let url):
					viewModel.videoUrl = url
				case .failure(let error):
					networkError = error
				}
				dispatchGroup.leave()
			})
        } else {
            if let imageUrlString = slideModel.image, let imageUrl = URL(string: imageUrlString) {
                viewModel.type = .image
                dispatchGroup.enter()
				getData(imageUrl, completion: { result in
					switch result {
					case .success(let url):
						viewModel.imageUrl = url
					case .failure(let error):
						networkError = error
					}
					dispatchGroup.leave()
				})
            }
			if let frontImage = slideModel.frontImage, let frontImageUrl = URL(string: frontImage) {
				dispatchGroup.enter()
				getData(frontImageUrl, completion: { result in
					switch result {
					case .success(let url):
						viewModel.frontImageUrl = url
					case .failure(let error):
						networkError = error
					}
					dispatchGroup.leave()
				})
			}
            if let storageDir = slideModel.track?.storageDir, let trackUrl = URL(string: storageDir) {
                viewModel.type = .track
                dispatchGroup.enter()
				getData(trackUrl, completion: { result in
					switch result {
					case .success(let url):
						viewModel.trackUrl = url
					case .failure(let error):
						networkError = error
					}
					dispatchGroup.leave()
				})
            }
        }
        dispatchGroup.notify(queue: .main) {
            if let error = networkError {
				completion(.failure(error))
            } else {
				completion(.success(viewModel))
            }
        }
    }
	
	func prevStory() -> StoryModel? {
		if let stories = stories,
			stories.count > currentStoryIndex.storyIndex,
			currentStoryIndex.storyIndex - 1 >= 0 {
			return stories[currentStoryIndex.storyIndex - 1]
		}
		return nil
	}
	
	func nextStory() -> StoryModel? {
		if let stories = stories,
			stories.count > currentStoryIndex.storyIndex + 1 {
			return stories[currentStoryIndex.storyIndex + 1]
		}
		return nil
	}
	
	func preloadNextSlide() {
		if let stories = stories,
			stories.count > currentStoryIndex.storyIndex,
			stories[currentStoryIndex.storyIndex].data.dataSlides.count > stories[currentStoryIndex.storyIndex].currentIndex + 1 {
			addDownloadQueue(slideModel: stories[currentStoryIndex.storyIndex].data.dataSlides[stories[currentStoryIndex.storyIndex].currentIndex + 1])
		}
	}
	
	func preloadNextStory() {
		let nextStoryIndex = currentStoryIndex.storyIndex + 1
		if let stories = stories, stories.count > nextStoryIndex, stories[nextStoryIndex].data.dataSlides.count > 0 {
			addDownloadQueue(slideModel: stories[nextStoryIndex].data.dataSlides[0])
		}
	}
	
	func preloadPreviousStory() {
		let prevStoryIndex = currentStoryIndex.storyIndex - 1
		if let stories = stories,
			stories.count > prevStoryIndex,
			prevStoryIndex >= 0,
			stories[prevStoryIndex].data.dataSlides.count > 0 {
			addDownloadQueue(slideModel: stories[prevStoryIndex].data.dataSlides[0])
		}
	}
    
    private func addDownloadQueue(slideModel: SlideModel) {
        let block = { [weak self] in
            self?.isDownloading = true
			self?.getData(slideModel, completion: { _ in
				self?.isDownloading = false
				self?.storyesPredownloadQueueRemoveLast()
				self?.preDownloadNextSlide()
			})
        }
        storyesPredownloadQueue.insert(block, at: 0)
        preDownloadNextSlide()
    }
    
    private func preDownloadNextSlide() {
        if let predownloadItem = storyesPredownloadQueue.last, isDownloading == false {
            predownloadItem()
        }
    }
    
    private func storyesPredownloadQueueRemoveLast() {
        _ = storyesPredownloadQueue.removeLast()
    }
}
