import UIKit
import WebKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let contentController = WKUserContentController()
        let dirtyStateHandler = NeedsSaveStateHandler { needsSave in
            print("needsSave state changed \(needsSave)")
        }
        dirtyStateHandler.add(to: contentController)
        let config = WKWebViewConfiguration()

        config.userContentController = contentController

        let webView = SomeWebView(frame: .zero, configuration: config)

        webView.frame = view.bounds
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(webView)

        let url = Bundle.main.url(forResource: "blah", withExtension: "html")!
        webView.loadFileURL(url, allowingReadAccessTo: url)
        let request = URLRequest(url: url)
        webView.load(request)
    }
}

class NeedsSaveStateHandler: WKContentRuleList, WKScriptMessageHandler {
    private let handleNeedsSaveStateChange: ((Bool) -> Void)!

    init(handleNeedsSaveStateChange: @escaping (Bool) -> Void) {
        self.handleNeedsSaveStateChange = handleNeedsSaveStateChange
    }

    func add(to contentController: WKUserContentController) {
        contentController.add(self, name: "setNeedsSave")

        let script = "function setEmbeddedNeedsSaveState(needsSave) { webkit.messageHandlers.setNeedsSave.postMessage(needsSave); }"
        let userScript = WKUserScript(source: script, injectionTime: .atDocumentStart, forMainFrameOnly: true)
        contentController.addUserScript(userScript)
    }

    func userContentController(_: WKUserContentController, didReceive message: WKScriptMessage) {
        let needsSave = message.body as? Int == 1
        handleNeedsSaveStateChange(needsSave)
    }
}

class SomeWebView: WKWebView {}
