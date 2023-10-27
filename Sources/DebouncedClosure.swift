import Foundation

final class DebouncedClosure<Input> {
    private let wrappedClosure: (Input) -> Void
    private let makeAndStartScheduler: (@escaping () -> Void) -> Scheduler
    
    private var scheduler: Scheduler?

    init(
        wrappedClosure: @escaping (Input) -> Void,
        makeAndStartScheduler: @escaping (@escaping () -> Void) -> Scheduler
    ) {
        self.wrappedClosure = wrappedClosure
        self.makeAndStartScheduler = makeAndStartScheduler
    }

    func callAsFunction(_ input: Input) {
        scheduler?.cancel()
        scheduler = makeAndStartScheduler() {
            self.wrappedClosure(input)
        }
    }
    
    func closure() -> (Input) -> Void { callAsFunction }
}

final class DebouncedClosureAsync<Input> {
    private let wrappedClosure: (Input) async -> Void
    private let makeAndStartScheduler: (@escaping () async -> Void) -> Scheduler
    
    private var scheduler: Scheduler?

    init(
        wrappedClosure: @escaping (Input) async -> Void,
        makeAndStartScheduler: @escaping (@escaping () async -> Void) -> Scheduler
    ) {
        self.wrappedClosure = wrappedClosure
        self.makeAndStartScheduler = makeAndStartScheduler
    }

    func callAsFunction(_ input: Input) {
        scheduler?.cancel()
        scheduler = makeAndStartScheduler() {
            await self.wrappedClosure(input)
        }
    }
    
    func closure() -> (Input) async -> Void { callAsFunction }
}
