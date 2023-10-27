import XCTest
@testable import DebouncedClosure

final class DebouncedClosureIntegrationTests: XCTestCase {
    let closureCallChecker = BlockCallChecker<Int, Void>(())
    var numberOfIterations = 1000
    
    func test_CallDebouncedClosure_DoesNotCalled_BeforeDebounceInterval() {
        let expectation = XCTestExpectation(description: "closure call")
        expectation.isInverted = true
        let debouncedClosure = debounced(expectation.fulfill, 2.2)
        
        debouncedClosure(())
        
        wait(for: [expectation], timeout: 2.1)
    }
    
    func test_CallDebouncedClosure_CalledAfterDebounceInterval() {
        let expectation = XCTestExpectation(description: "closure call")
        let debouncedClosure = debounced(expectation.fulfill, 2.2)
        
        debouncedClosure(())
        
        wait(for: [expectation], timeout: 2.2)
    }
    
    func test_SeveralConsequentCallsToDebouncedClosure_OnlyLastCallExecuted() {
        let expectation = XCTestExpectation(description: "closure call")
        let testClosure: (Int) -> Void = { i in
            if i == self.numberOfIterations { expectation.fulfill() }
            self.closureCallChecker.closure()(i)
        }
        let debouncedClosure = debounced(testClosure, 0.1)
        
        for i in 1...numberOfIterations { debouncedClosure(i) }
        
        wait(for: [expectation], timeout: 10)
        XCTAssertEqual(closureCallChecker.inputs, [numberOfIterations])
    }
    
    func test_SeveralConsequentCalls_WithIntervalMoreThanDebounce_AllCallsExecuted() {
        let expectation1 = XCTestExpectation(description: "closure call #1")
        let expectation2 = XCTestExpectation(description: "closure call #2")
        let testClosure: (Int) -> Void = { i in
            if i == 1 { expectation1.fulfill() }
            if i == 2 { expectation2.fulfill() }
            self.closureCallChecker.closure()(i)
        }
        let debouncedClosure = debounced(testClosure, 0.1)
        
        debouncedClosure(1)
        wait(for: [expectation1], timeout: 0.2)
        
        debouncedClosure(2)
        wait(for: [expectation2], timeout: 0.2)
        
        XCTAssertEqual(closureCallChecker.inputs, [1, 2])
    }
    
    func test_SeveralConsequentCallsToDebouncedClosure_WithThreadBlockedLongerThanDebounce_OnlyLastCallExecuted() {
        numberOfIterations = 5
        let expectation = XCTestExpectation(description: "closure call")
        let testClosure: (Int) -> Void = { i in
            if i == self.numberOfIterations { expectation.fulfill() }
            self.closureCallChecker.closure()(i)
        }
        let debouncedClosure = debounced(testClosure, 0.1)
        
        for i in 1...numberOfIterations {
            debouncedClosure(i)
            /* Blocks current thread and so the timer hitches as bu default `debounced` scheduled on current RunLoop in defaukt mode
             And hence the expectation that all closures will be executed is wrong */
            sleep(1)
        }
        
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(closureCallChecker.inputs, [numberOfIterations])
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
