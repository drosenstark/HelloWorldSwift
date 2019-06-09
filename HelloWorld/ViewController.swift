import UIKit

class ViewController: UIViewController {
    let vc = AnotherVC()

    override func viewDidLoad() {
        super.viewDidLoad()
        ExampleInSwift().doSomething(example: ExampleInObjc())
        self.view.addSubview(vc.view)
    }
}

class AnotherVC: UIViewController {
    override func viewDidLoad() {
        print("yes I actually did get called")
    }
}
