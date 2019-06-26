import UIKit
import WebKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let contentController = WKUserContentController()
        let dirtyStateHandler = DirtyStateHandler { dirty in
            print("dirty state changed \(dirty)")
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

class DirtyStateHandler: WKContentRuleList, WKScriptMessageHandler {
    private let handleDirtyChange: ((Bool) -> Void)!

    init(handleDirtyChange: @escaping (Bool) -> Void) {
        self.handleDirtyChange = handleDirtyChange
    }

    func add(to contentController: WKUserContentController) {
        contentController.add(self, name: "setDirty")

        let script = "function setEmbeddedDirtyState(dirty) { webkit.messageHandlers.setDirty.postMessage(dirty); }"
        let userScript = WKUserScript(source: script, injectionTime: .atDocumentStart, forMainFrameOnly: true)
        contentController.addUserScript(userScript)
    }

    func userContentController(_: WKUserContentController, didReceive message: WKScriptMessage) {
        let dirtyState = message.body as? Int == 1
        handleDirtyChange(dirtyState)
    }
}

class SomeWebView: WKWebView {}
