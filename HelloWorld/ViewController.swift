import UIKit
import WebKit

class ViewController: UIViewController {

    let ruleList = RuleList()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .green
        ExampleInSwift().doSomething(example: ExampleInObjc())

        let contentController = WKUserContentController();
        contentController.add(ruleList, name: "whatever")

        let config = WKWebViewConfiguration()
        config.userContentController = contentController

        let webView = SomeWebView(frame: .zero, configuration: config)

        webView.frame = view.bounds
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(webView)


        let url = Bundle.main.url(forResource: "blah", withExtension: "html")!
        webView.loadFileURL(url, allowingReadAccessTo: url)
        let request = URLRequest(url: url)
        webView.load(request)

        ruleList.callback = {
            webView.removeFromSuperview()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            webView.evaluateJavaScript("whatever()", completionHandler: nil)
        }
    }
}

class RuleList: WKContentRuleList, WKScriptMessageHandler {

    var callback: (()->())!
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print("got a message \(message)")
        callback()
    }
}

class SomeWebView: WKWebView {

}

