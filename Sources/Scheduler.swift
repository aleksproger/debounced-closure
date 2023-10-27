import Foundation

/// Protocol to hide custom scheduler implementations and allow clients to provide own implementation of schedulers for debounce
public protocol Scheduler {
    /// Cancel previously scheduled action
    func cancel()
}

extension Timer: Scheduler {
    public func cancel() { invalidate() }
}

extension Task: Scheduler {}

/// A set of predefined and configured schedulers
@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
public enum Schedulers {
    /// Creates a scheduler that uses `Timer` as an implementation for debounce
    case timer(Duration)
    
    /// Creates a scheduler that uses `Task` and `Task.sleep` as an implementation for debounce
    case task(Duration, ((Error) -> Void)? = nil)
    
    var makeAndStart: (@escaping () -> Void) -> Scheduler {
        switch self {
        case let .timer(interval):
            { block in
                Timer.scheduledTimer(withTimeInterval: Double(interval.components.attoseconds) / attosecondsInSecond, repeats: false) { timer in
                    timer.invalidate()
                    block()
                }
            }
        case let .task(interval, handleError):
            { block in
                Task {
                    do { try await Task.sleep(for: interval) }
                    catch { handleError?(error) }
                    guard !Task.isCancelled else { return }
                    block()
                }
            }
        }
    }
}

private let attosecondsInSecond: Double = 1_000_000_000_000_000_000
