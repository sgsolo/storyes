import UIKit

protocol StoriesServiceInput {
    var stories: [StoryModel]? { get }
    func getStories(success: Success?, failure: Failure?)
    func getData(_ url: URL, success: Success?, failure: Failure?)
    func preDownloadStory(storyModel: StoryModel)
    func preDownloadStories()
    func addDownloadQueue(slideModel: SlideModel)
}

struct Story {
    var storyIndex: Int = 0 {
        didSet {
            slideIndex = 0
        }
    }
    var slideIndex: Int = 0
}

class StoriesService: StoriesServiceInput {
    static let shared = StoriesService()
    
    var stories: [StoryModel]?
    var storyesPredownloadQueue: [() -> Void] = []
    var isDownloading = false
    private var apiClient: ApiClientInput = ApiClient()
    
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
    
    func preDownloadStory(storyModel: StoryModel) {
        storyModel.data.dataSlides.forEach { slideModel in
            getData(slideModel, success: nil, failure: nil)
        }
    }
    
    func preDownloadStories() {
        self.stories?.forEach { storyModel in
            storyModel.data.dataSlides.forEach { slideModel in
                getData(slideModel, success: nil, failure: nil)
            }
        }
    }
    
    func addDownloadQueue(slideModel: SlideModel) {
        let block = {
            self.isDownloading = true
            let block = { [weak self] in
                self?.isDownloading = false
                self?.removeDownloadQueue()
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
    
    private func removeDownloadQueue() {
        _ = storyesPredownloadQueue.removeLast()
    }
}
