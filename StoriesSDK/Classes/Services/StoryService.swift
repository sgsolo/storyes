import UIKit

protocol StoriesServiceInput: class {
    var stories: [StoryModel]? { get }
	var currentStoryIndex: StoryIndex { get set }
    func getStories(success: Success?, failure: Failure?)
    func getData(_ slideModel: SlideModel, success: Success?, failure: Failure?)
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
	
    func getStories(success: Success?, failure: Failure?) {
        apiClient.getCarusel(success: { data in
            guard let data = data as? Data else { return }
            do {
                let stories = try JSONDecoder().decode(StoriesModel.self, from: data)
                self.stories = stories.stories
                success?(stories)
            }
            catch {
                print(error)
                failure?(error)
            }
        }, failure: { error in
            print(error)
            failure?(error)
        })
    }
    
    func getData(_ url: URL, success: Success?, failure: Failure?) {
        apiClient.getData(url, success: success, failure: failure)
    }
    
    func getData(_ slideModel: SlideModel, success: Success?, failure: Failure?) {
        var viewModel = SlideViewModel()
        viewModel.fillFromSlideModel(slideModel)
        let dispatchGroup = DispatchGroup()
        var networkError: Error?
		if let storageDir = slideModel.video?.storageDir, let videoUrl = URL(string: storageDir) {
            viewModel.type = .video
            dispatchGroup.enter()
            getData(videoUrl, success: { videoUrl in
                if let videoUrl = videoUrl as? URL {
                    viewModel.videoUrl = videoUrl
                }
                dispatchGroup.leave()
            }, failure: { error in
                networkError = error
                dispatchGroup.leave()
            })
        } else {
            if let imageUrlString = slideModel.image, let imageUrl = URL(string: imageUrlString) {
                viewModel.type = .image
                dispatchGroup.enter()
                getData(imageUrl, success: { imageUrl in
                    if let imageUrl = imageUrl as? URL {
                        viewModel.imageUrl = imageUrl
                    }
                    dispatchGroup.leave()
                }, failure: { error in
                    networkError = error
                    dispatchGroup.leave()
                })
            }
			if let frontImage = slideModel.frontImage, let frontImageUrl = URL(string: frontImage) {
				dispatchGroup.enter()
				getData(frontImageUrl, success: { frontImageUrl in
					if let frontImageUrl = frontImageUrl as? URL {
						viewModel.frontImageUrl = frontImageUrl
					}
					dispatchGroup.leave()
				}, failure: { error in
					networkError = error
					dispatchGroup.leave()
				})
			}
            if let storageDir = slideModel.track?.storageDir, let trackUrl = URL(string: storageDir) {
                viewModel.type = .track
                dispatchGroup.enter()
                getData(trackUrl, success: { localTrackUrl in
                    if let localTrackUrl = localTrackUrl as? URL {
                        viewModel.trackUrl = localTrackUrl
                    }
                    print(trackUrl)
                    dispatchGroup.leave()
                }, failure: { error in
                    networkError = error
                    dispatchGroup.leave()
                })
            }
        }
        dispatchGroup.notify(queue: .main) {
            if let error = networkError {
                failure?(error)
            } else {
                success?(viewModel)
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
        let block = {
            self.isDownloading = true
            let block = { [weak self] in
                self?.isDownloading = false
                self?.storyesPredownloadQueueRemoveLast()
                self?.preDownloadNextSlide()
            }
            self.getData(slideModel, success: { _ in
                block()
            }, failure: { error in
                block()
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
