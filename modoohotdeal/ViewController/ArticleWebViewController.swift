//
//  ArticleWebViewController.swift
//  modoohotdeal
//
//  Created by baedy on 2019/12/24.
//  Copyright © 2019 baedy. All rights reserved.
//

import UIKit
import WebKit
import RxSwift
import SafariServices

class ArticleWebViewController: UIViewController {

    @IBOutlet weak var container : UIView!
    
    var webView: WKWebView!
    private var url : URL!
    var titleText = ""
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        configure()
    }
    
    func configure(){
//        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 0.2549019608, green: 0.7843137255, blue: 0.1764705882, alpha: 1)
//        webView = WKWebView.init(frame: self.view.frame)
        self.title = titleText
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14)]
        self.navigationItem.hidesBackButton = true
        let image = #imageLiteral(resourceName: "back").resizeImage(size: CGSize(width: 35, height: 35))
        image.withRenderingMode(.alwaysOriginal)
        let leftButton = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(self.backTabAction))

        leftButton.image = leftButton.image?.withRenderingMode(.alwaysOriginal)

        self.navigationItem.leftBarButtonItem = leftButton
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        
        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences        
        
        webView = WKWebView(frame: view.bounds, configuration: configuration)
        container.addSubview(webView)
        
        self.webView.navigationDelegate = self
        self.webView.uiDelegate = self
        
        guard self.url != nil else { return }
        
        var request = URLRequest(url: self.url)
        request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 7_0 like Mac OS X) AppleWebKit/537.51.1 (KHTML, like Gecko) Version/7.0 Mobile/11A465 Safari/9537.53", forHTTPHeaderField: "User-Agent")
        self.webView.load(request)
        
        
    }
    
    @objc func backTabAction(){
        self.navigationController?.popViewController(animated: true)
    }
    
    func setURL(url : URL){
        self.url = url
    }
    
}

extension ArticleWebViewController : WKScriptMessageHandler{
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print("WKScriptMessage : \(message)")
    }
}

extension ArticleWebViewController : WKUIDelegate{
    func webView(_: WKWebView, previewingViewControllerForElement: WKPreviewElementInfo, defaultActions: [WKPreviewActionItem]) -> UIViewController?{
        print("WKPreviewElementInfo")
        return nil
    }
    
    func webView(_ createWebViewWith: WKWebViewConfiguration, for: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView?{
        
        print("createWebViewWith")
        return nil
    }
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        print("alert : \(message)")
        if message == "존재하지 않는 글입니다."{
            AlertService.shared().alertInit(title: "안내", message: "존재하지 않는 글입니다", preferredStyle: .alert)
                .addAction(title: "확인", style: .cancel){ alert in
                    self.navigationController?.popViewController(animated: true)
                }
                    .showAlert()
        }
        completionHandler()
    }
}

extension ArticleWebViewController : WKNavigationDelegate{
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print("didCommit")
        self.indicatorAnimate(isAnimate: true)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("didFinish")
        self.indicatorAnimate(isAnimate: false)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("didFail")
        self.indicatorAnimate(isAnimate: false)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("didStartProvisionalNavigation")
    }
    
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        print("didReceiveServerRedirectForProvisionalNavigation")
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("didFailProvisionalNavigation")
    }
    
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        print("didReceive challenge: URLAuthenticationChallenge")
        
        completionHandler(.performDefaultHandling, nil)
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        print("decidePolicyFor navigationAction : \(navigationAction)")
        
        if navigationAction.navigationType == .linkActivated {
            guard let url = navigationAction.request.url else {return}
            sfvcCallRequest(url)
        }
        if (navigationAction.request.url?.absoluteString.contains("google") ?? false) || (navigationAction.request.url?.absoluteString.contains("adex") ?? false){
            decisionHandler(.cancel)
            return
        }
        print("ad? decidePolicyFor navigationAction : \(navigationAction)")
        decisionHandler(.allow)
    }
    
    func sfvcCallRequest(_ url: URL){
        let vc = SFSafariViewController.init(url: url)
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        print("decidePolicyFor navigationResponse")
        decisionHandler(.allow)
    }
    
    func indicatorAnimate(isAnimate ani: Bool){
        self.loadingIndicator.isHidden = !ani
        ani ? self.loadingIndicator.startAnimating() : self.loadingIndicator.stopAnimating()
    }
}
