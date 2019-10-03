
import Foundation

protocol CacheServiceInput {
	func getViewModel(slideModel: SlideModel) -> SlideViewModel?
	func getUrlWith(stringUrl: String) -> URL?
	func saveToCacheIfNeeded(_ url: URL, currentLocation: URL) -> URL?
}

class CacheService: CacheServiceInput {
	static let shared = CacheService()
	private let fileManager = FileManager.default
	private lazy var baseUrl: URL? = {
		var documentsUrl = self.fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first
		documentsUrl?.appendPathComponent("StoriesSdkCacheDirectory")
		if let documentsUrl = documentsUrl, !fileManager.fileExists(atPath: documentsUrl.absoluteString) {
			try? fileManager.createDirectory(at: documentsUrl, withIntermediateDirectories: true, attributes: nil)
		}
		return documentsUrl
	}()
	
	func getViewModel(slideModel: SlideModel) -> SlideViewModel? {
		var viewModel = SlideViewModel(slideModel: slideModel)
		if let video = slideModel.video, let videoUrl = video.storageDir, let _ = URL(string: videoUrl) {
			viewModel.type = .video
			if let url = self.getUrlWith(stringUrl: videoUrl) {
				viewModel.videoUrl = url
			} else {
				return nil
			}
			return viewModel
		} else {
			if let imageUrlString = slideModel.image, let _ = URL(string: imageUrlString) {
				viewModel.type = .image
				if let url = self.getUrlWith(stringUrl: imageUrlString) {
					viewModel.imageUrl = url
				} else {
					return nil
				}
			}
			if let frontImageUrlString = slideModel.frontImage, let _ = URL(string: frontImageUrlString) {
				viewModel.type = .image
				if let url = self.getUrlWith(stringUrl: frontImageUrlString) {
					viewModel.frontImageUrl = url
				} else {
					return nil
				}
			}
			if let track = slideModel.track, let trackUrl = track.storageDir, let _ = URL(string: trackUrl) {
				viewModel.type = .track
				if let url = self.getUrlWith(stringUrl: trackUrl) {
					viewModel.trackUrl = url
				} else {
					return nil
				}
			}
			return viewModel
		}
	}
	
	func getUrlWith(stringUrl: String) -> URL? {
		guard let url = URL(string: stringUrl) else {
			return nil
		}
		if let directoryUrl = cacheDirectoryFor(url), fileManager.fileExists(atPath: directoryUrl.path) {
			return directoryUrl
		} else {
			return nil
		}
	}
	
	func saveToCacheIfNeeded(_ url: URL, currentLocation: URL) -> URL? {
		if let destinationUrl = cacheDirectoryFor(url),
			!fileManager.fileExists(atPath: destinationUrl.path),
			let _ = try? fileManager.moveItem(at: currentLocation, to: destinationUrl) {
			return destinationUrl
		}
		return nil
	}

	func cacheDirectoryFor(_ url: URL) -> URL? {
		let fileURL = url.path
		let valueAddingPercentEncoding = fileURL.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
		let cacheUrl = baseUrl?.appendingPathComponent(valueAddingPercentEncoding)
		return cacheUrl
	}
}
