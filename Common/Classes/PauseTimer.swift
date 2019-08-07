import UIKit

//TODO: Выннести функциональность работы с таймером из FullScreenPresenter-а в PauseTimer
//class PauseTimer {
//
//	private let timer: Timer? = nil
//	private var pauseStartDate: Date? = nil
//	private var previousFireDate: Date? = nil
//
//	private func pauseTimer() {
//		guard let timer = self.timer else { return }
//		pauseStartDate = Date()
//		previousFireDate = timer.fireDate
//		timer.fireDate = Date.distantFuture
//	}
//
//	private func resumeTimer() {
//		guard let pauseStartDate = pauseStartDate, let previousFireDate = previousFireDate else { return }
//		let pauseTime = pauseStartDate.timeIntervalSinceNow * -1
//		self.timer?.fireDate = Date(timeInterval: pauseTime, since: previousFireDate)
//	}
//
//}
