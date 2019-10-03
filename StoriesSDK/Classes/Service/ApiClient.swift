import Foundation

typealias Parametrs = Dictionary<String, String>
let timeoutInterval: TimeInterval = 120

enum HTTPMethod: String {
	case get = "GET"
	case post = "POST"
}

enum ApiEndPoint: String {
	case bunkerStoriesMusic = "/v1/cat?node=/stories/stories-music&version=latest"
}

protocol ApiClientInput {
	func getStories(completion: @escaping (Result<Data, Error>) -> Void)
	func getData(_ url: URL, completion: @escaping (Result<URL, Error>) -> Void)
}

extension ApiClient: ApiClientInput {
	public	func getStories(completion: @escaping (Result<Data, Error>) -> Void) {
		guard let urlRequest = getRequest(ApiEndPoint.bunkerStoriesMusic.rawValue) else { return }
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

	static let sharedUrlSession: URLSession = {
		let configuration = URLSessionConfiguration.default
		configuration.timeoutIntervalForRequest = timeoutInterval
		configuration.timeoutIntervalForResource = timeoutInterval
		return URLSession(configuration: configuration, delegate: ApiClientDelegate(), delegateQueue: nil)
	}()
	
	private let cacheService: CacheServiceInput
	private let urlSession: URLSession
	private let baseURLString = "http://bunker-api-dot.yandex.net"
	private var taskPool = SafeArray<URLSessionTask>()
	private let downloadQueue = DispatchQueue(label: "DownloadQueue", attributes: .concurrent)
	private static var tasks = SafeDictionary<URL, DispatchSemaphore>()
	
	init(urlSession: URLSession, cacheService: CacheServiceInput) {
		self.urlSession = urlSession
		self.cacheService = cacheService
	}
	
	private func getRequest(_ path: String, _ params: Parametrs? = nil) -> URLRequest? {
		var urlString = baseURLString + path
		urlString = self.createUrl(urlString, params)
		if let url = URL(string: urlString) {
			var urlRequest = URLRequest(url: url)
			urlRequest.httpMethod = HTTPMethod.get.rawValue
			urlRequest.timeoutInterval = timeoutInterval
			return urlRequest
		} else {
			return nil
		}
	}
	
	private func dataTask(_ urlRequest: URLRequest, completion: @escaping (Result<Data, Error>) -> Void) {
		let task = urlSession.dataTask(with: urlRequest) { data, response, error in
			let httpResponse = response as? HTTPURLResponse
			if let error = error {
				print("REQUEST ERROR \(String(describing: response?.url)) \(error as NSError)")
				DispatchQueue.main.async {
					completion(.failure(error))
				}
				return
			}
			
			let statusCode = httpResponse?.statusCode ?? 0
			if (200...299).contains(statusCode) {
				if let data = data, !data.isEmpty {
					DispatchQueue.main.async {
						completion(.success(data))
					}
				} else {
					let error = NSError(domain: "Empty data", code: statusCode, userInfo: nil)
					DispatchQueue.main.async {
						completion(.failure(error))
					}
				}
			} else {
				let error = NSError(domain: "Invalid status code", code: statusCode, userInfo: nil)
				DispatchQueue.main.async {
					completion(.failure(error))
				}
			}
		}
		task.resume()
		taskPool.append(task)
	}
	
	private func downloadTask(_ url: URL, completion: @escaping (Result<URL, Error>) -> Void) {
		if let destinationUrl = self.cacheService.getUrlWith(stringUrl: url.absoluteString) {
			DispatchQueue.main.async {
				completion(.success(destinationUrl))
			}
			return
		}
		
		downloadQueue.async { [weak self] in
			guard let self = self else { return }
			
			if let semaphore = ApiClient.tasks[url] {
				semaphore.wait()
				semaphore.signal()
				DispatchQueue.main.async {
					if let localUrl = self.cacheService.getUrlWith(stringUrl: url.absoluteString) {
						completion(.success(localUrl))
					} else {
						let error = NSError(domain: "Url not contains in cache", code: 0, userInfo: nil)
						completion(.failure(error))
					}
				}
				return
			}
			ApiClient.tasks[url] = DispatchSemaphore(value: 0)
			
			let task = self.urlSession.downloadTask(with: url) { location, response, error in
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
					if let destinationUrl = self.cacheService.saveToCacheIfNeeded(url, currentLocation: location) {
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
