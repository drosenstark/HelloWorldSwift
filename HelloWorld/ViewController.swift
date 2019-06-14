import UIKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        ExampleInSwift().doSomething(example: ExampleInObjc())
        let asyncController = DispatchQueue.main.asyncAfterWithCancel(deadline: .now() + 1.0, execute: {
            print("Yeah I'm ok")
            return "Thing!"
        } as ()->(String), handler: { thing in
            print("Got it \(thing)")
        })
        asyncController.canceled = false
    }
}

extension DispatchQueue {
    class AsyncController<T> {
        var canceled = false
        let handler: (T)->()
        init(handler: @escaping (T)->()) {
            self.handler = handler
        }
    }
    
    func asyncAfterWithCancel<T>(deadline: DispatchTime, execute work: @escaping ()->(T), handler: @escaping (T)->()) -> AsyncController<T> {
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
