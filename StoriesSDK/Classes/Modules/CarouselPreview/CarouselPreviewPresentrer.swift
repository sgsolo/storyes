protocol CarouselPreviewPresentrerInput {
	func scrollTo(storyIndex: Int)
	func getStoryFrame(at storyIndex: Int) -> CGRect
    func storiesDidLoad(stories: [StoryModel])
}

protocol CarouselPreviewPresentrerOutput: class {
	func didSelectStory(at index: Int, frame: CGRect)
}

final class CarouselPreviewPresentrer {
    weak var view: CarouselViewInput!
	weak var output: CarouselPreviewPresentrerOutput!
    private(set) var stories: [StoriePreviewModel] = []
    private(set) var viewAppear = false
}

extension CarouselPreviewPresentrer: CarouselViewOutput {
    func viewWillAppear() {
        guard viewAppear == false else {
            return
        }
        view.showLoadingView()
        viewAppear = true
        if !stories.isEmpty {
            let sectionData = CollectionSectionData(objects: self.stories)
            view.showData([sectionData])
        }
    }
	
    func didSelectCollectionCell(at indexPath: IndexPath, frame: CGRect) {
		output.didSelectStory(at: indexPath.item, frame: frame)
	}
}

extension CarouselPreviewPresentrer: CarouselPreviewPresentrerInput {
    func scrollTo(storyIndex: Int) {
		view.scrollTo(storyIndex: storyIndex)
	}
	
	func getStoryFrame(at storyIndex: Int) -> CGRect {
		return view.getStoryFrame(at: storyIndex)
	}
    
    func storiesDidLoad(stories: [StoryModel]) {
        stories.forEach { story in
            self.stories.append(StoriePreviewModel(with: story.data))
        }
        let sectionData = CollectionSectionData(objects: self.stories)
        if viewAppear {
            view.showData([sectionData])
        }
        loadImages()
    }
    
    private func loadImages() {
        // TODO: make image loading queue
        for (index, story) in stories.enumerated() {
            guard let url = URL(string: story.imageURL) else {
                continue
            }
            StoriesService.shared.getData(url, success: { [weak self] data in
                guard let imageLocalURL = data as? URL,
                    let imageData = try? Data(contentsOf: imageLocalURL) else {
                    return
                }
                story.image = UIImage(data: imageData)
                if self?.viewAppear == true {
                    self?.view.updateCarousel(index: index)
                }
            }, failure: nil)
        }
    }
}
