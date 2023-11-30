//
//  streamManagerViewController.swift
//  ReptiMate


import UIKit
import WebKit

class streamManagerViewController: UIViewController,WKScriptMessageHandler {
    
    let VCfunc : VCfunc = .init()
    
    @IBOutlet weak var closeBtn: UIButton!
    
    @IBOutlet weak var chatView: UIView!
    
    var refreshToken = ""
    var accessToken = ""
    var idx = ""
    var nickname = ""
    var profilePath = ""
    
    var finished = false
    var finishedduration = ""
    var url = "https://web.reptimate.store/"
    var boardIdx = ""
  
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTap()
        self.swipeRecognizer()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        webViewInit()
    }
    
    func webViewInit(){
        accessToken = UserDefaults.standard.string(forKey: "accessToken")!
        refreshToken = UserDefaults.standard.string(forKey: "refreshToken")!
        idx = UserDefaults.standard.string(forKey: "idx")!
        nickname = UserDefaults.standard.string(forKey: "nickname")!
        profilePath = UserDefaults.standard.string(forKey: "profilePath")!
                
        do {
            if let cookie = try HTTPCookie(properties: [
                .domain: "web.reptimate.store",
                .path: "/",
                .name: "myAppCookie",
                .value: "{\"accessToken\" : \"\(accessToken)\",\"refreshToken\" : \"\(refreshToken)\",\"idx\" : \"\(idx)\",\"profilePath\" : \"\(profilePath)\",\"nickname\" : \"\(nickname)\"}",
                .secure: true,
            ]) {
                var setUrl = self.url+"streamhost/"+boardIdx
                // 쿠키 생성 성공한 경우
                let preferences = WKWebpagePreferences()
                preferences.allowsContentJavaScript = true
                
                let userContentController = WKUserContentController()
                userContentController.add(self, name: "consoleLogHandler")
                let configuration = WKWebViewConfiguration()
                configuration.userContentController = userContentController
                configuration.defaultWebpagePreferences = preferences
                
                let uctionWebView = WKWebView(frame: self.chatView.bounds, configuration: configuration)
                uctionWebView.scrollView.bounces = true
                uctionWebView.navigationDelegate = self
                uctionWebView.uiDelegate = self
                uctionWebView.autoresizingMask = [.flexibleWidth, . flexibleHeight]
                uctionWebView.scrollView.showsVerticalScrollIndicator = false
                uctionWebView.scrollView.showsHorizontalScrollIndicator = false
                uctionWebView.allowsBackForwardNavigationGestures = true
                
                uctionWebView.scrollView.minimumZoomScale = 1.0
                uctionWebView.scrollView.maximumZoomScale = 1.0
                
                uctionWebView.scrollView.minimumZoomScale = 1.0
                uctionWebView.scrollView.maximumZoomScale = 1.0
                
                
                uctionWebView.configuration.websiteDataStore.httpCookieStore.setCookie(cookie) {
                   // 쿠키 등록 완료 후 처리
                    self.chatView.addSubview(uctionWebView)
                    print("쿠키등록 -> 웹뷰 로드")
                    var urlString = ""

                    if let url = URL(string: setUrl) {
                        let request = URLRequest(url: url)
                        uctionWebView.load(request)
                        print("===========urlString : ")
                        print(setUrl)
                        print("===============================")
                    }
                }
            } else {
                print("쿠키 생성 실패")
            }
        } catch let error {
            print("쿠키 생성 중 오류 발생: \(error)")
        }

    }
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "consoleLogHandler", let logMessage = message.body as? String {
            print("JavaScript 콘솔 출력: \(logMessage)")
        }
    }
    
    @IBAction func closeBtnTapped(_ sender: Any) {
//        dismiss(animated: true)
        self.navigationController?.popViewController(animated: true)
    }
    
        
    private func timeFormatted(_ totalSeconds: Int) -> String {
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = (totalSeconds % 3600) % 60
            
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}
extension streamManagerViewController: WKNavigationDelegate {
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
    
        print("\(navigationAction.request.url?.absoluteString ?? "")" )
        
        decisionHandler(.allow)
    }
}

extension streamManagerViewController: WKUIDelegate {

    public func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        
    }
    private func webView(_ webView: WKWebView, shouldPreviewElement elementInfo: WKContextMenuElementInfo) -> Bool {
        // Input 요소를 클릭하여 확대가 발생했을 때, 이벤트를 처리
        return false // 확대 막기
    }
}
