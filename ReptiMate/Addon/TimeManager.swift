import Foundation

class TimerManager {
    static let shared = TimerManager()
    
    private var timer: Timer?
    private var seconds = 0
    private var isTimerRunning = false
    
    private init() {}
    
    func startTimer() {
        seconds = 0
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        isTimerRunning = true
        NotificationCenter.default.post(name: Notification.Name("TimerUpdated"), object: nil)
    }
    
    @objc private func updateTimer() {
        seconds += 1
        // 타이머 업데이트 시, 다른 ViewController에 알림을 보낼 수 있습니다.
        NotificationCenter.default.post(name: Notification.Name("TimerUpdated"), object: nil)
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
        isTimerRunning = false
        NotificationCenter.default.post(name: Notification.Name("TimerUpdated"), object: nil)
    }
    
    func getCurrentTime() -> Int {
        return seconds
    }
    
    func isRunning() -> Bool {
        return isTimerRunning
    }
}
