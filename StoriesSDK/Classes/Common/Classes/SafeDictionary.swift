
import Foundation

class SafeDictionary<Key: Hashable, Value> {
	private var unsafeDictionary = Dictionary<Key, Value>()
	private let lock = NSRecursiveLock()
	
	subscript(key: Key) -> Value? {
		get {
			return lock.synchronized {
				return unsafeDictionary[key]
			}
		}
		set {
			lock.synchronized {
				unsafeDictionary[key] = newValue
			}
		}
	}
	
	var isEmpty: Bool {
		return lock.synchronized {
			return unsafeDictionary.isEmpty
		}
	}
	
	func removeAll() {
		lock.synchronized {
			unsafeDictionary.removeAll()
		}
	}
	
	func forEach(_ body: ((key: Key, value: Value)) -> Void) {
		lock.synchronized {
			unsafeDictionary.forEach(body)
		}
	}
}
