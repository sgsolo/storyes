public protocol CarouselPreviewPresentrerInput {}

protocol CarouselPreviewPresentrerOutput {}

public final class CarouselPreviewPresentrer {
    weak var view: CarouselPreviewInput!
}

extension CarouselPreviewPresentrer: CarouselPreviewOutput {
    public func viewDidLoad() {
        let mockData = MockStoriesPreviewData.storiesPreviewData()
        let sectionData = CollectionSectionData(objects: mockData)
        view.showData([sectionData])
    }
}

extension CarouselPreviewPresentrer: CarouselPreviewPresentrerOutput {}
