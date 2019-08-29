
import Foundation

extension NSLocking {
	func synchronized(_ task: () -> Void) {
		lock()
		task()
		unlock()
	}
	
	func synchronized<T>(_ task: () -> T) -> T {
		lock()
		defer {
			unlock()
		}
		return task()
	}
}
