import Foundation
import Combine

class TimeModel: ObservableObject {
    @Published var hour: String = "00"
    @Published var minute: String = "00"
    @Published var second: String = "00"
    @Published var dateString: String = ""
    @Published var is24HourMode: Bool = true {
        didSet {
            updateTime()
        }
    }
    
    private var timer: AnyCancellable?
    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy年MM月dd日"
        return f
    }()
    
    init() {
        startTimer()
    }
    
    private func startTimer() {
        // Update immediately
        updateTime()
        
        // Sync to the exact second
        let now = Date()
        let calendar = Calendar.current
        let nanoseconds = calendar.component(.nanosecond, from: now)
        let delay = 1.0 - Double(nanoseconds) / 1_000_000_000
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            // Start the regular timer
            self?.timer = Timer.publish(every: 1, on: .main, in: .common)
                .autoconnect()
                .sink { _ in
                    self?.updateTime()
                }
            self?.updateTime()
        }
    }

    private func updateTime() {
        let now = Date()
        let h = calendar.component(.hour, from: now)
        let m = calendar.component(.minute, from: now)
        let s = calendar.component(.second, from: now)
        
        self.hour = String(format: "%02d", h)
        self.minute = String(format: "%02d", m)
        self.second = String(format: "%02d", s)
        self.dateString = dateFormatter.string(from: now)
    }
}
