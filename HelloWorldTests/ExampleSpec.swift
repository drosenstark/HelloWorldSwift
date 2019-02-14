@testable import HelloWorld
import Quick
import Nimble
import Kiwi

class ExampleInSwiftSpec: QuickSpec {
    var result: String = ""

    override func spec() {
        describe("ExampleInSwift") {
            var subject: ExampleInSwift!
            let objC = ExampleInObjc()

            beforeEach {
                subject = ExampleInSwift()
                ExampleInObjc().doSomething()
                ExampleInObjc.stub(#selector(ExampleInObjc.doSomethingClass))
                objC.stub(#selector(ExampleInObjc.doSomething)) { _ in
                    self.result = "yeah"
                    return nil
                }
            }
            context("when something") {
                it("does something") {
                    subject.doSomething(example: objC)
                    expect(subject.didSomething) == true
                    expect(self.result) == "yeah"
                }
            }
        }
    }
}
