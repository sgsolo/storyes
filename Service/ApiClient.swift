import Foundation

typealias Success = ((Any?) -> Void)
typealias Failure = ((Error) -> Void)

typealias Parametrs = Dictionary<String, String>

protocol ApiClientInput {
	// TODO: for test
	func getCarusel(success: Success?, failure: Failure?)
}

extension ApiClient: ApiServiceInput {
	// TODO: for test
	func getCarusel(success: Success?, failure: Failure?) {
		let urlRequest = getRequest("carusel")
		dataTask(urlRequest, success: success, failure: failure)
	}
}

class ApiClient {
	private let baseURLString = ""
	private var taskPool: [URLSessionDataTask] = []

	private func getRequest(_ path: String, _ params: Parametrs? = nil) -> URLRequest {
		var url = baseURLString + path
		url = self.createUrl(url, params)
		var urlRequest = URLRequest(url: URL(string: url)!)
		urlRequest.httpMethod = "GET"
		urlRequest.timeoutInterval = 60
		urlRequest.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
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
		let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
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
		URLSession.shared.flush { }
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
