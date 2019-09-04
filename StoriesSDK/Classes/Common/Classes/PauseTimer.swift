import Foundation

class PauseTimer {
    
    var isTimerScheduled = false
    
    private var timer: Timer?
    private var pauseStartDate: Date?
    private var previousFireDate: Date?
    
    func scheduledTimer(withTimeInterval interval: TimeInterval, repeats: Bool, block: @escaping (Timer) -> Void) {
        invalidate()
        self.timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: repeats, block: block)
        isTimerScheduled = true
    }
    
    func invalidate() {
        self.timer?.invalidate()
        self.timer = nil
        
        self.pauseStartDate = nil
        self.previousFireDate = nil
        
        isTimerScheduled = false
    }
    
    func pause() {
        guard let timer = self.timer, self.previousFireDate == nil else { return }
        self.pauseStartDate = Date()
        self.previousFireDate = timer.fireDate
        timer.fireDate = Date.distantFuture
    }
    
    func resume() {
        guard let pauseStartDate = self.pauseStartDate, let previousFireDate = self.previousFireDate else { return }
        let pauseTime = pauseStartDate.timeIntervalSinceNow * -1
        self.timer?.fireDate = Date(timeInterval: pauseTime, since: previousFireDate)
        self.previousFireDate = nil
    }
    
}
