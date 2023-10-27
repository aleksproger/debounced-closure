import XCTest
@testable import DebouncedClosure

final class DebouncedClosureUnitTests: XCTestCase {
    private let timer = MockTimer()
    private let closureCallChecker = BlockCallChecker<Void, Void>(())
    private lazy var timerFactory = {
        let factory = MockTimerFactory()
        factory.result = self.timer
        return factory
    }()
    
    func test_CallDebouncedClosure_SetsToExecuteOnTimer() {
        let debouncedClosure = debounced(closureCallChecker.closure(), timerFactory.makeTimer)
        
        debouncedClosure(())
        
        XCTAssertEqual(timerFactory.inputs, [.makeTimer(interval: timerFactory.interval)])
    }
    
    func test_CallDebouncedClosure_SetsTheCorrectClosureInTimer() {
        let debouncedClosure = debounced(closureCallChecker.closure(), timerFactory.makeTimer)
        
        debouncedClosure(())
        timerFactory.blocks.forEach { $0() }
        
        XCTAssertEqual(closureCallChecker.count, 1)
    }
    
    func test_CallDebouncedClosureSecondTime_InvalidatesTimer_BeforeSchedulingSecondTime() {
        let debouncedClosure = debounced(closureCallChecker.closure(), timerFactory.makeTimer)
        
        debouncedClosure(())
        debouncedClosure(())
        timerFactory.blocks.forEach { $0() }
        
        XCTAssertEqual(timer.invalidateCallsCount, 1)
    }
}


final class MockTimer: Timer {
    enum Input: Equatable {
        case scheduledTimer(interval: TimeInterval, repeats: Bool)
        case invalidate
    }
    
    private(set) static var staticInputs = [Input]()
    private(set) var inputs = [Input]()
    
    var scheduledBlocks: [@Sendable (Timer) -> Void] = []
    override class func scheduledTimer(
        withTimeInterval interval: TimeInterval,
        repeats: Bool,
        block: @escaping @Sendable (Timer) -> Void
    ) -> Timer {
        staticInputs.append(.scheduledTimer(interval: interval, repeats: repeats))
        return MockTimer()
    }
    
    var invalidateCallsCount = 0
    override func invalidate() { invalidateCallsCount += 1 }
}


final class MockTimerFactory {
    enum Input: Equatable {
        case makeTimer(interval: TimeInterval)
    }
    
    private(set) var inputs = [Input]()
    private(set) var blocks: [() -> Void] = []
    
    var result = MockTimer()
    var interval = 2.0
    func makeTimer(block: @escaping () -> Void) -> Timer {
        inputs.append(.makeTimer(interval: interval))
        blocks.append(block)
        return result
    }
}

final class BlockCallChecker<Input, Output> {
    private(set) var count = 0
    private(set) var inputs = [Input]()
    
    let result: Output

    init(_ result: Output) {
        self.result = result
    }

    func callAsFunction(_ input: Input) -> Output {
        count += 1
        inputs.append(input)
        return result
    }
    
    func closure() -> (Input) -> Output { callAsFunction }
}
