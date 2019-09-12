import Foundation

public typealias Success = ((Any?) -> Void)
public typealias Failure = ((Error) -> Void)

typealias Parametrs = Dictionary<String, String>

protocol ApiClientInput {
	// TODO: for test
	func getCarusel(success: Success?, failure: Failure?)
	func getTrack(_ urlString: String, success: Success?, failure: Failure?)
	func getImage(_ urlString: String, success: Success?, failure: Failure?)
}

extension ApiClient: ApiClientInput {
	// TODO: for test
	public	func getCarusel(success: Success?, failure: Failure?) {
		guard let urlRequest = getRequest("http://bunker-api-dot.yandex.net/v1/cat?node=/stories/stories-music&version=latest") else { return }
		//TODO: "MOCK удалить позже"
		if YStoriesManager.needUseMockData, let path = Bundle(for: ApiClient.self).path(forResource: "stories.json", ofType: nil) {
			if let data = FileManager.default.contents(atPath: path) {
				success?(data)
				return
			}
		} else {
			dataTask(urlRequest, success: success, failure: failure)
		}
	}

	public func getTrack(_ urlString: String, success: Success?, failure: Failure?) {
		downloadTask(urlString, success: success, failure: failure)
	}
	
	public func getImage(_ urlString: String, success: Success?, failure: Failure?) {
		dataTaskForImage(urlString, success: success, failure: failure)
	}
}

class ApiClient {

	private let cacheManager: CacheServiceInput = CacheService()
	private let baseURLString = ""
	private var taskPool = SafeArray<URLSessionTask>()
	private let downloadQueue = DispatchQueue(label: "DownloadQueue", attributes: .concurrent)
	private static var tasks = SafeDictionary<URL, DispatchSemaphore>()
	static var apiSession: URLSession = {
		let configuration = URLSessionConfiguration.default
		return URLSession(configuration: configuration)
	}()

	static var imageSession: URLSession = {
		let configuration = URLSessionConfiguration.default
		configuration.httpMaximumConnectionsPerHost = 1
		configuration.httpShouldUsePipelining = false
		configuration.urlCache = URLCache(memoryCapacity: Int.max, diskCapacity: Int.max, diskPath: "imageCache")
		return URLSession(configuration: configuration)
	}()

	static var playerSession: URLSession = {
		let configuration = URLSessionConfiguration.default
		configuration.timeoutIntervalForRequest = 120
		configuration.timeoutIntervalForResource = 120
		return URLSession(configuration: configuration)
	}()
	
	private func getRequest(_ path: String, _ params: Parametrs? = nil) -> URLRequest? {
		var urlString = baseURLString + path
		urlString = self.createUrl(urlString, params)
		if let url = URL(string: urlString) {
			var urlRequest = URLRequest(url: url)
			urlRequest.httpMethod = "GET"
			urlRequest.timeoutInterval = 120
			return urlRequest
		} else {
			return nil
		}
	}
	
	private func postRequest(_ path: String, _ params: Parametrs? = nil) -> URLRequest? {
		let url = baseURLString + path
		if let url = URL(string: url) {
			var request = URLRequest(url: url)
			request.httpMethod = "POST"
			request.timeoutInterval = 120
			request.setValue("application/json", forHTTPHeaderField: "Content-Type")
			if let params = params, let serializedData = try? JSONSerialization.data(withJSONObject: params, options: []) {
				request.httpBody = serializedData
			}
			return request
		} else {
			return nil
		}
	}
	
	private func dataTask(_ urlRequest: URLRequest, success: Success?, failure: Failure?) {
		let task = ApiClient.apiSession.dataTask(with: urlRequest) { data, response, error in
			let httpResponse = response as? HTTPURLResponse
			if let e = error {
				print("REQUEST ERROR \(String(describing: response?.url)) \(e as NSError)")
				DispatchQueue.main.async {
					failure?(e)
				}
				return
			}
			
			if [200, 201, 204].contains(httpResponse?.statusCode) {
				if let data = data, !data.isEmpty {
//					let json = try? JSONSerialization.jsonObject(with: data, options: [])
					DispatchQueue.main.async {
						success?(data)
					}
				} else {
					DispatchQueue.main.async {
						success?(nil)
					}
				}
			} else if httpResponse?.statusCode != 304 {
				let e = NSError(domain: "Invalid status code", code: httpResponse?.statusCode ?? 0, userInfo: nil)
				DispatchQueue.main.async {
					failure?(e)
				}
			}
		}
		task.resume()
		taskPool.append(task)
	}
	
	private func dataTaskForImage(_ urlString: String, success: Success?, failure: Failure?) {
		guard let url = URL(string: urlString) else {
			failure?(NSError(domain: "Invalid URL \(urlString)", code: 0, userInfo: nil))
			return
		}
		let task = ApiClient.imageSession.dataTask(with: url) { data, response, error in
			let httpResponse = response as? HTTPURLResponse
			if let e = error {
				print("REQUEST ERROR \(String(describing: response?.url)) \(e as NSError)")
				DispatchQueue.main.async {
					failure?(e)
				}
				return
			}
			
			if [200, 201, 204].contains(httpResponse?.statusCode) {
				if let data = data, !data.isEmpty {
					DispatchQueue.main.async {
						success?(data)
					}
				} else {
					DispatchQueue.main.async {
						success?(nil)
					}
				}
			} else if httpResponse?.statusCode != 304 {
				let e = NSError(domain: "Invalid status code", code: httpResponse?.statusCode ?? 0, userInfo: nil)
				DispatchQueue.main.async {
					failure?(e)
				}
			}
		}
		task.resume()
		taskPool.append(task)
	}
	
	private func downloadTask(_ urlString: String, success: Success?, failure: Failure?) {
		guard let url = URL(string: urlString) else {
			failure?(NSError(domain: "Invalid URL \(urlString)", code: 0, userInfo: nil))
			return
		}
		
		if let destinationUrl = self.cacheManager.getUrlWith(stringUrl: url.absoluteString) {
			DispatchQueue.main.async {
				success?(destinationUrl)
			}
			return
		}
		
		downloadQueue.async {
			
			if let semaphore = ApiClient.tasks[url] {
				semaphore.wait()
				semaphore.signal()
				DispatchQueue.main.async {
					self.cacheManager.getUrlWith(stringUrl: url.absoluteString,
												 success: { destinationUrl in
													success?(destinationUrl) },
												 failure: { error in
													print(error)
													failure?(error) })
				}
				return
			}
			ApiClient.tasks[url] = DispatchSemaphore(value: 0)
			
			let task = ApiClient.playerSession.downloadTask(with: url) { location, response, error in
				defer {
					let semaphore = ApiClient.tasks[url]
					ApiClient.tasks[url] = nil
					semaphore?.signal()
				}
				
				guard let location = location, error == nil else {
					if let error = error {
						DispatchQueue.main.async {
							print(error)
							failure?(error)
						}
					}
					return
				}
				if !Thread.isMainThread {
					DispatchQueue.main.sync {
						do {
							let destinationUrl = self.cacheManager.cacheDirectoryFor(url)
							try self.cacheManager.saveToCacheIfNeeded(destinationUrl, currentLocation: location)
							success?(destinationUrl)
						} catch {
							print(error)
							failure?(error)
						}
					}
				}
			}
			task.resume()
			self.taskPool.append(task)
		}
	}
	
	private func createUrl(_ baseUrl: String, _ params: Parametrs? = nil) -> String {
		var url = baseUrl
		if let params = params{
			url += "?"
			for (key, value) in params {
				guard let valueAddingPercentEncoding = value.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else { continue }
				url += "\(key)=\(valueAddingPercentEncoding)&"
			}
			url.removeLast()
		}
		return url
	}
	
	deinit {
		print("cancel")
		taskPool.forEach { $0.cancel() }
	}
}
