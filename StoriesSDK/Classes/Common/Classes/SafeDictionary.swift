
import Foundation

class SafeDictionary<Key: Hashable, Value> {
	private var data = Dictionary<Key, Value>()
	private let lock = NSRecursiveLock()
	
	subscript(key: Key) -> Value? {
		get {
			return lock.synchronized {
				return data[key]
			}
		}
		set {
			lock.synchronized {
				data[key] = newValue
			}
		}
	}
	
	var isEmpty: Bool {
		return lock.synchronized {
			return data.isEmpty
		}
	}
	
	func removeAll() {
		lock.synchronized {
			data.removeAll()
		}
	}
	
	func forEach(_ body: ((key: Key, value: Value)) -> Void) {
		lock.synchronized {
			data.forEach(body)
		}
	}
}
