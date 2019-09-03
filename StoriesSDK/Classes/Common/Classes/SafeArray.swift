
import Foundation

class SafeArray<Element> {
	private var unsafeArray = Array<Element>()
	private let lock = NSRecursiveLock()
	
	subscript(index: Int) -> Element {
		get {
			return lock.synchronized {
				return unsafeArray[index]
			}
		}
		set {
			lock.synchronized {
				unsafeArray[index] = newValue
			}
		}
	}
	
	var isEmpty: Bool {
		return lock.synchronized {
			return unsafeArray.isEmpty
		}
	}
	
	func removeAll() {
		lock.synchronized {
			unsafeArray.removeAll()
		}
	}
	
	func forEach(_ body: (_ element: Element) -> Void) {
		lock.synchronized {
			unsafeArray.forEach(body)
		}
	}
	
	func append(_ newElement: Element) {
		lock.synchronized {
			unsafeArray.append(newElement)
		}
	}
}

