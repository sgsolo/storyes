class StoriePreviewModel {
    let title: String
    var image: UIImage?
    var isViewed: Bool
    private(set) var imageURL: String
    
    init(with storyData: StoryData) {
        title = storyData.header
        imageURL = storyData.image
        isViewed = storyData.status
    }
}
