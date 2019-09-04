
import UIKit

class ShortTapGestureRecognizer: UITapGestureRecognizer {
	let touchDuration = 0.15
	var startTouchDate: Date?
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
		startTouchDate = Date()
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
		if let duration = startTouchDate?.timeIntervalSinceNow, self.touchDuration > -duration {
			self.state = .ended
		} else {
			self.state = .cancelled
		}
	}
}

