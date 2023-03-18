//
//  CustomWebView.swift
//  Monit
//
//  Created by 맥 on 2018. 1. 10..
//  Copyright © 2018년 맥. All rights reserved.
//

import UIKit
import WebKit

class CustomWebView: UIView, WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler {
    enum CALL_SCRIPT_TYPE: String {
        case signin = "signin"
        case openurl = "openurl"
        case closeWebView = "closeWebView"
    }
    
    var m_parent: BaseViewController?
    var activityIndicator: UIActivityIndicatorView?
    var webView: WKWebView!

    func openUrl(url: String) {
        if (webView == nil) {
            let contentController = WKUserContentController()
            let config = WKWebViewConfiguration()
            contentController.add(self, name: CALL_SCRIPT_TYPE.signin.rawValue)
            contentController.add(self, name: CALL_SCRIPT_TYPE.openurl.rawValue)
            contentController.add(self, name: CALL_SCRIPT_TYPE.closeWebView.rawValue)
            config.userContentController = contentController
            
            webView = WKWebView(frame: self.frame, configuration: config)
            //        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            webView.uiDelegate = self
            webView.navigationDelegate = self
            addSubview(webView)
        }
        webView.load(URLRequest(url: URL(string: url)!, timeoutInterval: 120))
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        activityIndicator?.removeFromSuperview()
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        activityIndicator?.frame = CGRect(x: frame.midX - 25, y: frame.midY - 25 , width: 50, height: 50)
        activityIndicator?.hidesWhenStopped = true
        activityIndicator?.startAnimating()
        self.perform(#selector(stopIndicator), with: nil, afterDelay: 3)
        
        addSubview(activityIndicator!)
    }
    
    @objc func stopIndicator() {
        self.activityIndicator?.removeFromSuperview()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.activityIndicator?.removeFromSuperview()
    }
    
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
//        completionHandler(URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!) )

        guard let serverTrust = challenge.protectionSpace.serverTrust else { return completionHandler(.useCredential, nil) }
        let exceptions = SecTrustCopyExceptions(serverTrust)
        SecTrustSetExceptions(serverTrust, exceptions)
        completionHandler(.useCredential, URLCredential(trust: serverTrust))
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
//        if let urlStr = navigationAction.request.url?.absoluteString{
//            Debug.print(urlStr)
//            if (urlStr == Config.MONIT_YK_LOGIN_URL) {
//                if let _parent = m_parent as? SigninMainMonitXHuggiesViewController {
////                    _parent.testSignin()
//                }
//                self.removeFromSuperview()
//            }
//        }
        decisionHandler(.allow)
    }
    
    @available(iOS 13.0, *)
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, preferences: WKWebpagePreferences, decisionHandler: @escaping (WKNavigationActionPolicy, WKWebpagePreferences) -> Void) {
        preferences.preferredContentMode = .mobile
        decisionHandler(.allow, preferences)
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if(message.name == CALL_SCRIPT_TYPE.signin.rawValue){
            Debug.print("callScript Body:\(message.body)", event: .warning)
//            NativePopupManager.instance.toast(message: message.body as! String)
            if let _parent = m_parent as? SigninMainMonitXHuggiesViewController {
                _parent.scriptCallSignin(value: message.body as! String)
            }
//            self.removeFromSuperview()
        }
        if(message.name == CALL_SCRIPT_TYPE.openurl.rawValue){
            Debug.print("callScript Body:\(message.body)", event: .warning)
//            NativePopupManager.instance.toast(message: message.body as! String)
            if let _parent = m_parent as? SigninMainMonitXHuggiesViewController {
                _parent.scriptCallOpenUrl(url: message.body as! String)
            }
//            self.removeFromSuperview()
        }
        if(message.name == CALL_SCRIPT_TYPE.closeWebView.rawValue) {
            Debug.print("callScript Body:\(message.body)", event: .warning)
            //            NativePopupManager.instance.toast(message: message.body as! String)
            if let _parent = m_parent as? SigninMainMonitXHuggiesViewController {
                _parent.scriptCallCloseWebView(value: message.body as! String)
            }
        }
    }
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        
        NativePopupManager.instance.onlyContents(message: message, completionHandler: completionHandler)

//        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .actionSheet)
//
//        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
//            completionHandler()
//        }))
//
//        m_parent?.present(alertController, animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {

        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            completionHandler(true)
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
            completionHandler(false)
        }))
        
        m_parent?.present(alertController, animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        
        let alertController = UIAlertController(title: nil, message: prompt, preferredStyle: .actionSheet)
        
        alertController.addTextField { (textField) in
            textField.text = defaultText
        }
        
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            if let text = alertController.textFields?.first?.text {
                completionHandler(text)
            } else {
                completionHandler(defaultText)
            }
            
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
            
            completionHandler(nil)
            
        }))
        
        m_parent?.present(alertController, animated: true, completion: nil)
    }
}


