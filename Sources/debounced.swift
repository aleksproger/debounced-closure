import Foundation

/// Each time the closure called before `interval` passes, the previous action will be cancelled and the next
/// action will be scheduled to run after that time passes again. This mean that the action will only execute
/// after changes to the value stay unmodified for the specified `interval`.
///
/// > Warning: Call to `debounced()` produces new closure with the appropriate state, so it's no intended to be calles multiple times and will produce incorrect behavior.
/// ```swift
/// TextField("Text", text: $text)
/// .onChange(of: text, perform: debounced(Logger.log, 1)) - ❌
/// ```
///
/// - Parameters:
///   - closure: A closure to apply debounce logic at.
///   - interval: An interval to debounce in seconds. The call to the closure won't be performed until the interval passes, if some more calls made during the interval - timer resets.
public func debounced<T>(
    _ closure: @escaping (T) -> Void,
    _ interval: TimeInterval
) -> (T) -> Void {
    DebouncedClosure(
        wrappedClosure: closure,
        makeAndStartScheduler: { block in
            Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { timer in
                timer.invalidate()
                block()
            }
        }
    ).closure()
}

/// Each time the closure called before `interval` passes, the previous action will be cancelled and the next
/// action will be scheduled to run after that time passes again. This mean that the action will only execute
/// after changes to the value stay unmodified for the specified `interval`.
///
/// > Warning: Call to `debounced()` produces new closure with the appropriate state, so it's no intended to be calles multiple times and will produce incorrect behavior.
/// ```swift
/// TextField("Text", text: $text)
/// .onChange(of: text, perform: debounced(Logger.log, 1)) - ❌
/// ```
///
/// - Parameters:
///   - closure: A closure to apply debounce logic at.
///   - interval: An interval to debounce for. The call to the closure won't be performed until the interval passes, if some more calls made during the interval - timer resets.
@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
public func debounced<T>(
    _ closure: @escaping (T) -> Void,
    _ interval: Duration
) -> (T) -> Void {
    DebouncedClosure(
        wrappedClosure: closure,
        makeAndStartScheduler: { block in
            Timer.scheduledTimer(
                withTimeInterval: TimeInterval(interval.components.seconds),
                repeats: false
            ) { timer in
                timer.invalidate()
                block()
            }
        }
    ).closure()
}

/// Each time the closure called before `interval` passes, the previous action will be cancelled and the next
/// action will be scheduled to run after that time passes again. This mean that the action will only execute
/// after changes to the value stay unmodified for the specified `interval`.
///
/// > Warning: Call to `debounced()` produces new closure with the appropriate state, so it's no intended to be calles multiple times and will produce incorrect behavior.
/// ```swift
/// TextField("Text", text: $text)
/// .onChange(of: text, perform: debounced(Logger.log, 1)) - ❌
/// ```
///
/// - Parameters:
///   - closure: A closure to apply debounce logic at.
///   - scheduler: Option to choose between underlying implementation of scheduler (`Task` or `Timer`)
@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
public func debounced<T>(
    _ closure: @escaping (T) -> Void,
    _ scheduler: Schedulers
) -> (T) -> Void {
    DebouncedClosure(
        wrappedClosure: closure,
        makeAndStartScheduler: scheduler.makeAndStart
    ).closure()
}

/// Each time the closure called before `interval` passes, the previous action will be cancelled and the next
/// action will be scheduled to run after that time passes again. This mean that the action will only execute
/// after changes to the value stay unmodified for the specified `interval`.
///
/// > Warning: Call to `debounced()` produces new closure with the appropriate state, so it's no intended to be calles multiple times and will produce incorrect behavior.
/// ```swift
/// TextField("Text", text: $text)
/// .onChange(of: text, perform: debounced(Logger.log, 1)) - ❌
/// ```
/// 
/// - Parameters:
///   - closure: A closure to apply debounce logic at.
///   - interval: An interval to debounce in seconds. The call to the closure won't be performed until the interval passes, if some more calls made during the interval - timer resets.
///   - makeAndStartTimer: Allows the client to provide specific setup for the timer used to trigger the closure on interval expiration. Only for advanced users.
public func debounced<T>(
    _ closure: @escaping (T) -> Void,
    _ makeAndStartTimer: @escaping (@escaping () -> Void) -> Scheduler
) -> (T) -> Void {
    DebouncedClosure(
        wrappedClosure: closure,
        makeAndStartScheduler: { block in makeAndStartTimer(block) }
    ).closure()
}
