import Foundation
import SwiftUI

struct ExampleViewOne: View {
    @State 
    private var text = ""
    let log: (String) -> Void

    var body: some View {
        TextField("Text", text: $text)
            .onChange(of: text, perform: log)
    }
}

struct ExampleViewTwo: View {
    @State private var text = ""
    let debouncedLog = debounced(Logger.log, 1)

    var body: some View {
        TextField("Text", text: $text)
            .onChange(of: text, perform: debouncedLog)
    }
}

struct ExampleViewThree: View {
    @State private var text = ""

    var body: some View {
        TextField("Text", text: $text)
            .onChange(of: text, perform: debounced(Logger.log, 1))
    }
}

struct ExampleField<Content: View>: View {
    let isCorrect: Bool
    let name: String
    let content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Circle()
                    .fill(isCorrect ? .green : .red)
                    .frame(width: 10, height: 10)
                
                Text(name)
                    .font(.caption2)
                    .fontWeight(.bold)
            }
            content()
        }.padding()
    }
}

struct Logger {
    static func log(_ message: String) { print(message) }
}

struct DebounceExamples: PreviewProvider {
    static var previews: some View {
        VStack {
            ExampleField(isCorrect: true, name: "ExampleViewOne(log: debounced(Logger.log, 1))") {
                ExampleViewOne(log: debounced(Logger.log, 1))
            }
                    
            if #available(macOS 13.0, *) {
                ExampleField(isCorrect: true, name: "ExampleViewOne(log: debounced(Logger.log, .seconds(1)))") {
                    ExampleViewOne(log: debounced(Logger.log, .seconds(1)))
                }
                
                ExampleField(isCorrect: true, name: "ExampleViewOne(log: debounced(Logger.log, .timer(0.5)))") {
                    ExampleViewOne(log: debounced(Logger.log, .timer(.seconds(0.5))))
                }
                
                ExampleField(isCorrect: true, name: "ExampleViewOne(log: debounced(Logger.log, .task(1)))") {
                    ExampleViewOne(log: debounced(Logger.log, .task(.seconds(1))))
                }
            }
            
            ExampleField(isCorrect: true, name: "ExampleViewTwo()") {
                ExampleViewTwo()
            }
            
            ExampleField(isCorrect: false, name: "ExampleViewThree()") {
                ExampleViewThree()
            }
        }.padding()
    }
}
