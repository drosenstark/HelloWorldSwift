import UIKit

class ExampleInSwift: NSObject {
    var didSomething = false

    func doSomething(example: ExampleInObjc) {
        example.doSomething()
        didSomething = true
    }
}
