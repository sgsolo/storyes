import Foundation

public typealias Success = ((Any?) -> Void)
public typealias Failure = ((Error) -> Void)

typealias Parametrs = Dictionary<String, String>

public protocol ImageClientInput {
	// TODO: for test
	func getImage(_ urlString: String, success: Success?, failure: Failure?)
}

extension ApiClient: ImageClientInput {
	public func getImage(_ urlString: String, success: Success?, failure: Failure?) {
		dataTaskForImage(urlString, success: success, failure: failure)
	}
}

public protocol ApiClientInput {
	// TODO: for test
	func getCarusel(success: Success?, failure: Failure?)
}

extension ApiClient: ApiClientInput {
	// TODO: for test
 public	func getCarusel(success: Success?, failure: Failure?) {
		let urlRequest = getRequest("")
		dataTask(urlRequest, success: success, failure: failure)
	}
}

public class ApiClient {
	public init() {
		
	}
	
//	https://img2.goodfon.ru/original/2048x1365/2/92/priroda-nebo-oblaka-ozero.jpg
	private let baseURLString = "https://img2.goodfon.ru/original/2048x1365/2/92/priroda-nebo-oblaka-ozero.jpg"
	private var taskPool: [URLSessionDataTask] = []
	static var apiSession: URLSession = {
		let configuration = URLSessionConfiguration.default
		configuration.httpMaximumConnectionsPerHost = 1
		configuration.httpShouldUsePipelining = false
//		configuration.urlCache = URLCache(memoryCapacity: 500 * 1024 * 1024, diskCapacity: 500 * 1024 * 1024, diskPath: "apiCache")
		return URLSession(configuration: configuration)
	}()
	static var imageSession: URLSession = {
		let configuration = URLSessionConfiguration.default
		configuration.httpMaximumConnectionsPerHost = 1
		configuration.httpShouldUsePipelining = false
		configuration.urlCache = URLCache(memoryCapacity: 10000 * 1024 * 1024, diskCapacity: 10000 * 1024 * 1024, diskPath: "imageCache")
		return URLSession(configuration: configuration)
	}()

	private func getRequest(_ path: String, _ params: Parametrs? = nil) -> URLRequest {
		var url = baseURLString + path
		url = self.createUrl(url, params)
		var urlRequest = URLRequest(url: URL(string: url)!)
		urlRequest.httpMethod = "GET"
		urlRequest.timeoutInterval = 60
		urlRequest.cachePolicy = .returnCacheDataElseLoad
		urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
		return urlRequest
	}
	
	private func postRequest(_ path: String, _ params: Parametrs? = nil) -> URLRequest {
		let url = baseURLString + path
		
		var request = URLRequest(url: URL(string: url)!)
		request.httpMethod = "POST"
		request.timeoutInterval = 60
		request.setValue("application/json", forHTTPHeaderField: "Content-Type")
		if let params = params, let serializedData = try? JSONSerialization.data(withJSONObject: params, options: []) {
			request.httpBody = serializedData
		}
		return request
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
					let json = try? JSONSerialization.jsonObject(with: data, options: [])
					DispatchQueue.main.async {
						success?(json)
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
			failure?(NSError(domain: "Invalid URL", code: 0, userInfo: nil))
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
	
	private func createUrl(_ baseUrl: String, _ params: Parametrs? = nil) -> String {
		var url = baseUrl
		if let params = params{
			url += "?"
			for (key, value) in params {
				url += "\(key)=\(value.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)&"
			}
			url.removeLast()
		}
		return url
	}
	
	deinit {
		taskPool.forEach { $0.cancel() }
	}
}
