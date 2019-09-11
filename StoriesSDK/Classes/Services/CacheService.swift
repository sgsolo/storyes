
import Foundation

protocol CacheServiceInput {
	func getUrlWith(stringUrl: String, success: Success?, failure: Failure?)
	func getViewModel(slideModel: SlideModel) -> SlideViewModel?
	func getUrlWith(stringUrl: String) -> URL?
	func saveToCacheIfNeeded(_ directory: URL, currentLocation: URL) throws
	func cacheDirectoryFor(_ url: URL) -> URL
}

class CacheService: CacheServiceInput {
	static let shared = CacheService()
	private let fileManager = FileManager.default
	private lazy var cachesDirectoryUrl: URL = {
		let documentsUrl = self.fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
		return documentsUrl
	}()
	
	func getUrlWith(stringUrl: String, success: Success?, failure: Failure?) {
		guard let url = URL(string: stringUrl) else {
			failure?(NSError(domain: "Invalid URL \(stringUrl)", code: 0, userInfo: nil))
			return
		}
		let directoryUrl = cacheDirectoryFor(url)
		if fileManager.fileExists(atPath: directoryUrl.path) {
			success?(directoryUrl)
		} else {
			failure?(NSError(domain: "Url not contains in cache", code: 0, userInfo: nil))
		}
	}
	
	func getViewModel(slideModel: SlideModel) -> SlideViewModel? {
		var viewModel = SlideViewModel()
		viewModel.fillFromSlideModel(slideModel)
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
		let directoryUrl = cacheDirectoryFor(url)
		if fileManager.fileExists(atPath: directoryUrl.path) {
			return directoryUrl
		} else {
			return nil
		}
	}
	
	func saveToCacheIfNeeded(_ directory: URL, currentLocation: URL) throws {
		if !fileManager.fileExists(atPath: directory.path) {
			do {
				try fileManager.moveItem(at: currentLocation, to: directory)
			}
			catch {
				throw error
			}
		}
	}
	
	func cacheDirectoryFor(_ url: URL) -> URL {
		let fileURL = url.path
		let valueAddingPercentEncoding = fileURL.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
		let file = self.cachesDirectoryUrl.appendingPathComponent(valueAddingPercentEncoding)
		return file
	}
}
