import UIKit

public protocol StoriesServiceInput {
	var stories: StoriesModel? { get }
	func getStories(success: Success?, failure: Failure?)
}

public typealias StoryModel = [SlideModel]
public typealias StoriesModel = [StoryModel]

//TODO: StoryModel для теста вьюхи, после удалить
public struct SlideModel/*: Codable */{
	let duration = 6
	var color: UIColor
	var image: UIImage?
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
	
	var stories: StoriesModel? = [
		[SlideModel(color: .red, image: UIImage(named: "1", in: Bundle(for: FullScreenPresenter.self), compatibleWith: nil)),
		 SlideModel(color: .blue, image: UIImage(named: "1", in: Bundle(for: FullScreenPresenter.self), compatibleWith: nil)),
		 SlideModel(color: .brown, image: UIImage(named: "1", in: Bundle(for: FullScreenPresenter.self), compatibleWith: nil)),
		 SlideModel(color: .green, image: UIImage(named: "1", in: Bundle(for: FullScreenPresenter.self), compatibleWith: nil)),
		 SlideModel(color: .purple, image: UIImage(named: "1", in: Bundle(for: FullScreenPresenter.self), compatibleWith: nil))]
		,
		[SlideModel(color: .red, image: UIImage(named: "2", in: Bundle(for: FullScreenPresenter.self), compatibleWith: nil)),
		 SlideModel(color: .blue, image: UIImage(named: "2", in: Bundle(for: FullScreenPresenter.self), compatibleWith: nil)),
		 SlideModel(color: .brown, image: UIImage(named: "2", in: Bundle(for: FullScreenPresenter.self), compatibleWith: nil)),
		 SlideModel(color: .green, image: UIImage(named: "2", in: Bundle(for: FullScreenPresenter.self), compatibleWith: nil)),
		 SlideModel(color: .purple, image: UIImage(named: "2", in: Bundle(for: FullScreenPresenter.self), compatibleWith: nil))]
		,
		[SlideModel(color: .red, image: UIImage(named: "3", in: Bundle(for: FullScreenPresenter.self), compatibleWith: nil)),
		 SlideModel(color: .blue, image: UIImage(named: "3", in: Bundle(for: FullScreenPresenter.self), compatibleWith: nil)),
		 SlideModel(color: .brown, image: UIImage(named: "3", in: Bundle(for: FullScreenPresenter.self), compatibleWith: nil)),
		 SlideModel(color: .green, image: UIImage(named: "3", in: Bundle(for: FullScreenPresenter.self), compatibleWith: nil)),
		 SlideModel(color: .purple, image: UIImage(named: "3", in: Bundle(for: FullScreenPresenter.self), compatibleWith: nil))]
		,
		[SlideModel(color: .red, image: UIImage(named: "4", in: Bundle(for: FullScreenPresenter.self), compatibleWith: nil)),
		 SlideModel(color: .blue, image: UIImage(named: "4", in: Bundle(for: FullScreenPresenter.self), compatibleWith: nil)),
		 SlideModel(color: .brown, image: UIImage(named: "4", in: Bundle(for: FullScreenPresenter.self), compatibleWith: nil)),
		 SlideModel(color: .green, image: UIImage(named: "4", in: Bundle(for: FullScreenPresenter.self), compatibleWith: nil)),
		 SlideModel(color: .purple, image: UIImage(named: "4", in: Bundle(for: FullScreenPresenter.self), compatibleWith: nil))]
		,
		[SlideModel(color: .red, image: UIImage(named: "5", in: Bundle(for: FullScreenPresenter.self), compatibleWith: nil)),
		 SlideModel(color: .blue, image: UIImage(named: "5", in: Bundle(for: FullScreenPresenter.self), compatibleWith: nil)),
		 SlideModel(color: .brown, image: UIImage(named: "5", in: Bundle(for: FullScreenPresenter.self), compatibleWith: nil)),
		 SlideModel(color: .green, image: UIImage(named: "5", in: Bundle(for: FullScreenPresenter.self), compatibleWith: nil)),
		 SlideModel(color: .purple, image: UIImage(named: "5", in: Bundle(for: FullScreenPresenter.self), compatibleWith: nil))]
	]
	private var apiClient: ApiClientInput = ApiClient()
	
	func getStories(success: Success?, failure: Failure?) {
		success?(stories)
		apiClient.getCarusel(success: { data in
//			if let data = data as? Data, let storyes = try? JSONDecoder().decode(StoryesModel.self, from: data) {
//				self.storyes = storyes
//			success()
//			} else {
//              failure?()
//			}
		}, failure: { error in
			print(error)
			failure?(error)
		})
	}
}
