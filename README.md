# DebouncedClosure
## Simple and flexible way to debounce closure calls

DebouncedClosure is small and flexible implementation of debounce in modern Swift. 
It allows to achieve debounce for any arbitrary closure calls using minimalistic and consice syntax.

## Highlights

* **Simple and flexible API** just wrap your closure into `debounced(_ block:, _ interval:)` and you will receive debounced implementation
* **Tests** implementation contains tests
* **Lightwheight** the package is small and won't introduce any overheds to SPM resolve process
* **Flexible** underlying implementation can be changed from the client if neither `Task` nor `Timer` basic configurations are applicable


## Usage

#### Inject a debounced logger for observing TextField changes

The following code creates a debounced logger closure, which will fire events only after 1 second of idle in TextField

```swift
struct ExampleViewOne: View {
    @State 
    private var text = ""
    let log: (String) -> Void

    var body: some View {
        TextField("Text", text: $text)
            .onChange(of: text, perform: log)
    }
}

struct Logger {
    static func log(_ message: String) { print(message) }
}

ExampleViewOne(log: debounced(Logger.log, 1)) ✅

```

#### Inject a call to debounced function into, the client

The following code injects a call to `debounced(_ block:, _ interval:)` straight to the client code which called multiple times. 
It is incorrect as `debounced(_ block:, _ interval:)` acts as a factory for the debounced closure and thus will simply create multiple debounced closures

```swift
struct ExampleViewThree: View {
    @State 
    private var text = ""

    var body: some View {
        TextField("Text", text: $text)
            .onChange(of: text, perform: debounced(Logger.log, .seconds(1))) ❌
    }
}

struct Logger {
    static func log(_ message: String) { print(message) }
}

ExampleViewThree()

```

#### Illustration of examples from Sources/Examples

https://github.com/aleksproger/debounced-closure/assets/45671572/d7404e0a-9b35-40af-ac6b-7f534bf885f6

#### Different function signatures

- Using interval as `TimeInterval`
```swift
debounced(Logger.log, 1)
```
- Using interval as `Duration`
```swift
debounced(Logger.log, .seconds(1))
```

- Specifying one of predifined schedulers
```swift
debounced(Logger.log, .timer(.seconds(1))) or debounced(Logger.log, .task(.seconds(1)))
```

- Specifying custom scheduler
```swift
debounced(Logger.log) { block in CustomScheduler.start(with: block) }
```

## Requirements

* iOS 14.0+
* macOS 11.0+
* watchOS 7.0+
* tvOS 14.0+

## Installation

**SwiftPM:**

```swift
.package(url: "https://github.com/aleksproger/debounced-closure.git", .upToNextMajor(from: "1.0.0"))
```
