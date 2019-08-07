public protocol CarouselPreviewPresentrerInput {}

protocol CarouselPreviewPresentrerOutput {}

public final class CarouselPreviewPresentrer {
    weak var view: CarouselPreviewInput!
}

extension CarouselPreviewPresentrer: CarouselPreviewOutput {
    public func loadView() {
        view.showData(MockStoriesPreviewData.storiesPreviewData())
    }
}

extension CarouselPreviewPresentrer: CarouselPreviewPresentrerOutput {}
