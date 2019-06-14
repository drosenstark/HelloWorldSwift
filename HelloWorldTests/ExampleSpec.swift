@testable import HelloWorld
import Kiwi
import Nimble
import Quick

class ExampleInSwiftSpec: QuickSpec {
    var resultClassMethod: String = ""
    var result: String = ""

    override func spec() {
        describe("ExampleInSwift") {
            var subject: ExampleInSwift!
            let objC = ExampleInObjc()

            beforeEach {
                subject = ExampleInSwift()
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

            context("when calling class method") {
                beforeEach {
                    ExampleInObjc.stub(#selector(ExampleInObjc.doSomethingClass)) { _ in
                        self.resultClassMethod = "yes"
                        return nil
                    }
                }

                it("calls the stubbed method") {
                    ExampleInObjc.doSomethingClass()
                    expect(self.resultClassMethod) == "yes"
                }
            }
        }
    }
}
