public protocol CarouselPreviewPresentrerInput {
	func scrollTo(storyIndex: Int)
	func getStoryFrame(at storyIndex: Int) -> CGRect
}

public protocol CarouselPreviewPresentrerOutput: class {
	func didSelectStory(at index: Int, frame: CGRect)
}

public final class CarouselPreviewPresentrer {
    weak var view: CarouselPreviewInput!
	weak var output: CarouselPreviewPresentrerOutput!
}

extension CarouselPreviewPresentrer: CarouselPreviewOutput {
    public func viewDidLoad() {
        let mockData = MockStoriesPreviewData.storiesPreviewData()
        let sectionData = CollectionSectionData(objects: mockData)
        view.showData([sectionData])
    }
	
	public func didSelectCollectionCell(at indexPath: IndexPath, frame: CGRect) {
		output.didSelectStory(at: indexPath.item, frame: frame)
	}
}

extension CarouselPreviewPresentrer: CarouselPreviewPresentrerInput {
	public func scrollTo(storyIndex: Int) {
		view.scrollTo(storyIndex: storyIndex)
	}
	
	public func getStoryFrame(at storyIndex: Int) -> CGRect {
		return view.getStoryFrame(at: storyIndex)
	}
}
