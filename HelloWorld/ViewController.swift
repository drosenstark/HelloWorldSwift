import UIKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        ExampleInSwift().doSomething(example: ExampleInObjc())
        testWithoutReturn(cancel: true)
        testWithoutReturn(cancel: false)
        testWithReturn(cancel: true)
        testWithReturn(cancel: false)
    }

    func testWithReturn(cancel: Bool) {
        let cancelable: DispatchQueue.AsyncController<String> = DispatchQueue.main.asyncAfterWithCancel(deadline: .now() + 1.0, execute: {
            print("ran delayed block inside testWithReturn")
            return "Thing!"
        }) { thing in
            print("Got it \(thing)")
        }
        cancelable.canceled = cancel
    }

    func testWithoutReturn(cancel: Bool) {
        var cancelable = DispatchQueue.main.asyncAfterWithCancel(deadline: .now() + 1.0) {
            print("ran delayed block inside testWithoutReturn")
        }
        cancelable.canceled = cancel
    }
}

protocol Cancelable {
    var canceled: Bool { get set }
}

extension DispatchQueue {
    class AsyncController<T>: Cancelable {
        var canceled = false
        let handler: (T) -> Void
        init(handler: @escaping (T) -> Void) {
            self.handler = handler
        }
    }

    class Canceler: Cancelable {
        var canceled = false
    }

    func asyncAfterWithCancel(deadline: DispatchTime, execute work: @escaping () -> Void) -> Cancelable {
        let canceler = Canceler()

        asyncAfter(deadline: deadline) {
            guard canceler.canceled == false else { print("canceled!"); return }

            work()
        }
        return canceler
    }

    func asyncAfterWithCancel<T>(deadline: DispatchTime, execute work: @escaping () -> T, handler: @escaping (T) -> Void) -> AsyncController<T> {
        let asyncController = AsyncController(handler: handler)

        asyncAfter(deadline: deadline) {
            guard asyncController.canceled == false else { print("canceled!"); return }

            let result = work()
            handler(result)
        }
        return asyncController
    }
}

enum Result<T, Error> {
    case success(T)
    case failure(Error)
}
