import UIKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        ExampleInSwift().doSomething(example: ExampleInObjc())
    }
}
