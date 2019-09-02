import UIKit

public protocol StoriesServiceInput {
    var stories: StoriesModel? { get }
    func getStories(success: Success?, failure: Failure?)
    func getTrack(_ urlString: String, success: Success?, failure: Failure?)
    func preDownloadStory(storyModel: StoryModel)
    func preDownloadStories()
    func addDownloadQueue(slideModel: SlideModel)
}

public typealias StoriesModel = [StoryModel]

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
    
    var stories: StoriesModel?
    var storyesPredownloadQueue: [() -> Void] = []
    var isDownloading = false
    private var apiClient: ApiClientInput = ApiClient()
    
    func getStories(success: Success?, failure: Failure?) {
        apiClient.getCarusel(success: { data in
            guard let data = data as? Data else { return }
            do {
                let stories = try JSONDecoder().decode(StoryesJson.self, from: data)
                self.stories = stories.result.blocks.entities
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
    
    func getTrack(_ urlString: String, success: Success?, failure: Failure?) {
        apiClient.getTrack(urlString, success: success, failure: failure)
    }
    
    func getImage(_ urlString: String, success: Success?, failure: Failure?) {
        apiClient.getImage(urlString, success: success, failure: failure)
    }
    
    func getData(_ slideModel: SlideModel, success: Success?, failure: Failure?) {
        var viewModel = SlideViewModel()
        viewModel.fillFromSlideModel(slideModel)
        let dispatchGroup = DispatchGroup()
        var networkError: Error?
        if let video = slideModel.video, let videoUrl = video.videoUrl {
            viewModel.type = .video
            dispatchGroup.enter()
            getTrack(videoUrl, success: { videoUrl in
                if let videoUrl = videoUrl as? URL {
                    viewModel.videoUrl = videoUrl
                }
                dispatchGroup.leave()
            }, failure: { error in
                networkError = error
                dispatchGroup.leave()
            })
        } else {
            if let imageUrlString = slideModel.image {
                viewModel.type = .image
                dispatchGroup.enter()
                getTrack(imageUrlString, success: { imageUrl in
                    if let imageUrl = imageUrl as? URL {
                        viewModel.imageUrl = imageUrl
                    }
                    dispatchGroup.leave()
                }, failure: { error in
                    networkError = error
                    dispatchGroup.leave()
                })
            }
			if let frontImage = slideModel.frontImage {
				dispatchGroup.enter()
				getTrack(frontImage, success: { frontImageUrl in
					if let frontImageUrl = frontImageUrl as? URL {
						viewModel.frontImageUrl = frontImageUrl
					}
					dispatchGroup.leave()
				}, failure: { error in
					networkError = error
					dispatchGroup.leave()
				})
			}
            if let track = slideModel.track, let trackUrl = track.trackUrl {
                viewModel.type = .track
                dispatchGroup.enter()
                getTrack(trackUrl, success: { localTrackUrl in
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
        storyModel.dataSlides.forEach { slideModel in
            getData(slideModel, success: nil, failure: nil)
        }
    }
    
    func preDownloadStories() {
        self.stories?.forEach { storyModel in
            storyModel.dataSlides.forEach { slideModel in
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
