import UIKit

class ViewController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        ExampleInSwift().doSomething(example: ExampleInObjc())
    }
}
