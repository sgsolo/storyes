import Foundation

typealias Parametrs = Dictionary<String, String>

protocol ApiClientInput {
	func getCarusel(completion: @escaping (Result<Data, Error>) -> Void)
	func getData(_ url: URL, completion: @escaping (Result<URL, Error>) -> Void)
}

extension ApiClient: ApiClientInput {
	// TODO: for test
	public	func getCarusel(completion: @escaping (Result<Data, Error>) -> Void) {
		guard let urlRequest = getRequest("http://bunker-api-dot.yandex.net/v1/cat?node=/stories/stories-music&version=latest") else { return }
		//TODO: "MOCK удалить позже"
		if YStoriesManager.needUseMockData, let path = Bundle(for: ApiClient.self).path(forResource: "stories.json", ofType: nil) {
			if let data = FileManager.default.contents(atPath: path) {
				completion(.success(data))
				return
			}
		} else {
			dataTask(urlRequest, completion: completion)
		}
	}

	public func getData(_ url: URL, completion: @escaping (Result<URL, Error>) -> Void) {
		downloadTask(url, completion: completion)
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

	static var downloadSession: URLSession = {
		let configuration = URLSessionConfiguration.default
		configuration.timeoutIntervalForRequest = 120
		configuration.timeoutIntervalForResource = 120
		return URLSession(configuration: configuration, delegate: ApiClientDelegate(), delegateQueue: nil)
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
	
	private func dataTask(_ urlRequest: URLRequest, completion: @escaping (Result<Data, Error>) -> Void) {
		let task = ApiClient.apiSession.dataTask(with: urlRequest) { data, response, error in
			let httpResponse = response as? HTTPURLResponse
			if let error = error {
				print("REQUEST ERROR \(String(describing: response?.url)) \(error as NSError)")
				DispatchQueue.main.async {
					completion(.failure(error))
				}
				return
			}
			
			if [200, 201, 204].contains(httpResponse?.statusCode) {
				if let data = data, !data.isEmpty {
					DispatchQueue.main.async {
						completion(.success(data))
					}
				} else {
					let error = NSError(domain: "Empty data", code: httpResponse?.statusCode ?? 0, userInfo: nil)
					DispatchQueue.main.async {
						completion(.failure(error))
					}
				}
			} else {
				let error = NSError(domain: "Invalid status code", code: httpResponse?.statusCode ?? 0, userInfo: nil)
				DispatchQueue.main.async {
					completion(.failure(error))
				}
			}
		}
		task.resume()
		taskPool.append(task)
	}
	
	private func downloadTask(_ url: URL, completion: @escaping (Result<URL, Error>) -> Void) {
		if let destinationUrl = self.cacheManager.getUrlWith(stringUrl: url.absoluteString) {
			DispatchQueue.main.async {
				completion(.success(destinationUrl))
			}
			return
		}
		
		downloadQueue.async {
			
			if let semaphore = ApiClient.tasks[url] {
				semaphore.wait()
				semaphore.signal()
				DispatchQueue.main.async {
					if let localUrl = self.cacheManager.getUrlWith(stringUrl: url.absoluteString) {
						completion(.success(localUrl))
					} else {
						let error = NSError(domain: "Url not contains in cache", code: 0, userInfo: nil)
						completion(.failure(error))
					}
				}
				return
			}
			ApiClient.tasks[url] = DispatchSemaphore(value: 0)
			
			let task = ApiClient.downloadSession.downloadTask(with: url) { location, response, error in
				defer {
					let semaphore = ApiClient.tasks[url]
					ApiClient.tasks[url] = nil
					semaphore?.signal()
				}
				
				guard let location = location, error == nil else {
					if let error = error {
						DispatchQueue.main.async {
							print(error)
							completion(.failure(error))
						}
					}
					return
				}
				DispatchQueue.main.async {
					if let destinationUrl = self.cacheManager.saveToCacheIfNeeded(url, currentLocation: location) {
						completion(.success(destinationUrl))
					} else {
						let error = NSError(domain: "Url not contains in cache", code: 0)
						completion(.failure(error))
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

//https://st.yandex-team.ru/MSTORIES-54
class ApiClientDelegate: NSObject, URLSessionDelegate {
	func urlSession(_ session: URLSession,
					didReceive challenge: URLAuthenticationChallenge,
					completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
		guard let serverTrust = challenge.protectionSpace.serverTrust else {
				completionHandler(.rejectProtectionSpace, nil)
				return
		}
		completionHandler(.useCredential, URLCredential(trust: serverTrust))
	}
}
