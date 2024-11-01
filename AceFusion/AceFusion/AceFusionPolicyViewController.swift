//
//  AceFusionPolicyViewController.swift
//  AceFusion
//
//  Created by jin fu on 2024/11/1.
//

import UIKit
import WebKit
import Adjust

class AceFusionPolicyViewController: UIViewController , WKScriptMessageHandler, WKNavigationDelegate, WKUIDelegate{

    @IBOutlet weak var aceBackBtn: UIButton!
    @IBOutlet weak var aceWebView: WKWebView!
    @IBOutlet weak var aceIndView: UIActivityIndicatorView!
    
    //MARK: - Declare Variables
    var url: String?
    
    //MARK: - Declare IBAction
    @IBAction func btnBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.aceBackBtn.isHidden = self.url != nil
        self.aceIndView.hidesWhenStopped = true
        
        aceInitWebView()
    }
    
    func aceInitWebView() {
        self.aceWebView.backgroundColor = .black
        self.aceWebView.scrollView.backgroundColor = .black
        self.aceWebView.navigationDelegate = self
        self.aceWebView.uiDelegate = self
        
        let userContentC = self.aceWebView.configuration.userContentController
        let trackStr = """
        window.jsBridge = {
            openBrower: function(data) {
                window.webkit.messageHandlers.AceFusionActionHandle.postMessage(data)
            }
        };
        window.Adjust = {
            trackEvent: function(data) {
                window.webkit.messageHandlers.AceFusionEvenetHandle.postMessage(data)
            }
        };
        """
        let trackScript = WKUserScript(source: trackStr, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        userContentC.addUserScript(trackScript)
        userContentC.add(self, name: "AceFusionActionHandle")
        userContentC.add(self, name: "AceFusionEvenetHandle")
        
        self.aceIndView.startAnimating()
        if let adurl = url {
            if let urlRequest = URL(string: adurl) {
                let request = URLRequest(url: urlRequest)
                aceWebView.load(request)
            }
        } else {
            if let urlRequest = URL(string: "https://www.termsfeed.com/live/784dfdd7-e83a-4534-a4d1-50d2d6344b0d") {
                let request = URLRequest(url: urlRequest)
                aceWebView.load(request)
            }
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        DispatchQueue.main.async {
            self.aceIndView.stopAnimating()
        }
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        DispatchQueue.main.async {
            self.aceIndView.stopAnimating()
        }
    }

    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            if let url = navigationAction.request.url {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        return nil
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "AceFusionActionHandle" {
            if let data = message.body as? String {
                if let url = URL(string: data) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        } else if message.name == "AceFusionEvenetHandle" {
            if let data = message.body as? [String : Any] {
                print("AceFusionEvenetHandle: \(data)")
                if let evTok = data["eventToken"] as? String, !evTok.isEmpty {
                    Adjust.trackEvent(ADJEvent(eventToken: evTok))
                }
            }
        }
    }

}
