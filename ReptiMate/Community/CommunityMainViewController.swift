//
//  CommunityMainViewController.swift

import UIKit
import Alamofire
import WebKit
protocol DataTransferDelegate: AnyObject {
    func transferData(data: String)
}

class CommunityMainViewController: UIViewController, WKScriptMessageHandler {
    
    let VCfunc: VCfunc = .init()
    
    var refreshToken = ""
    var accessToken = ""
    var idx = ""
    var nickname = ""
    var profilePath = ""
    
    var cookieValue: Any? = nil
    var cookieString = ""
    var jsonObject = [String: Any]()

    @IBOutlet weak var webViewGroup: UIView!
    private var webView: WKWebView!
    var url = "https://web.reptimate.store/"
        
    var delegateData = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        if delegateData == "1" {
            // URL을 변경하고 웹뷰를 로드
            url = url + "?chat=1"
        } else {
            // 다른 경우의 URL 및 로드 로직 처리
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        webViewInit()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.delegateData = ""
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
                // 쿠키 생성 성공한 경우
                let preferences = WKWebpagePreferences()
                preferences.allowsContentJavaScript = true
                
                let userContentController = WKUserContentController()
                userContentController.add(self, name: "consoleLogHandler")
                
                let configuration = WKWebViewConfiguration()
                configuration.userContentController = userContentController
                configuration.defaultWebpagePreferences = preferences
                configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
                
                
                configuration.allowsInlineMediaPlayback = true
                configuration.mediaTypesRequiringUserActionForPlayback = .audio
                
                let uctionWebView = WKWebView(frame: self.webViewGroup.bounds, configuration: configuration)
                
                uctionWebView.scrollView.bounces = true
                uctionWebView.navigationDelegate = self
                uctionWebView.uiDelegate = self
                uctionWebView.autoresizingMask = [.flexibleWidth, . flexibleHeight]
                uctionWebView.scrollView.showsVerticalScrollIndicator = false
                uctionWebView.scrollView.showsHorizontalScrollIndicator = false
                uctionWebView.allowsBackForwardNavigationGestures = true
                
                uctionWebView.scrollView.minimumZoomScale = 1.0
                uctionWebView.scrollView.maximumZoomScale = 1.0
                uctionWebView.scrollView.bouncesZoom = false
                uctionWebView.scrollView.bounces = false
                uctionWebView.scrollView.isScrollEnabled = true
                
                uctionWebView.configuration.userContentController.addUserScript(self.getZoomDisableScript())
                uctionWebView.scrollView.delegate = self
                
                uctionWebView.configuration.websiteDataStore.httpCookieStore.setCookie(cookie) {
                   // 쿠키 등록 완료 후 처리
                    self.webViewGroup.addSubview(uctionWebView)
                    print("쿠키등록 -> 웹뷰 로드")
                    var urlString = self.url
                    if (self.delegateData.contains("1")) {
                        urlString = self.url+"?chat=1"
                    }
                    if let url = URL(string: urlString) {
                        let request = URLRequest(url: url)
                        uctionWebView.load(request)
                        print("===========urlString : ")
                        print(url)
                        print("==========================")
                    }
                }
            } else {
                print("쿠키 생성 실패")
            }
        } catch let error {
            print("쿠키 생성 중 오류 발생: \(error)")
        }
    }
    // JavaScript 메시지 핸들링
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "consoleLogHandler", let logMessage = message.body as? String {
            print("JavaScript 콘솔 출력: \(logMessage)")
        }
    }
    private func getZoomDisableScript() -> WKUserScript {
        let source: String = "var meta = document.createElement('meta');" +
            "meta.name = 'viewport';" +
            "meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';" +
            "var head = document.getElementsByTagName('head')[0];" + "head.appendChild(meta);"
        return WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
    }

    
}

extension CommunityMainViewController: UIScrollViewDelegate {
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
             scrollView.pinchGestureRecognizer?.isEnabled = false
    }
}

extension CommunityMainViewController: WKNavigationDelegate {
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        print("\(navigationAction.request.url?.absoluteString ?? "")" )
        decisionHandler(.allow)
    }
}

extension CommunityMainViewController: WKUIDelegate {
    public func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        
        let alertController = UIAlertController(title: message, message: nil, preferredStyle: .alert);
                
                let cancelAction = UIAlertAction(title: "확인", style: .cancel) {
                    _ in completionHandler()
                }
                
                alertController.addAction(cancelAction)
                DispatchQueue.main.async {
                    self.present(alertController, animated: true, completion: nil)
                }
    }
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
            
            let alertController = UIAlertController(title: message, message: nil, preferredStyle: .alert);
            
            let cancelAction = UIAlertAction(title: "취소", style: .cancel) {
                _ in completionHandler(false)
            }
            let okAction = UIAlertAction(title: "확인", style: .default) {
                _ in completionHandler(true)
            }
            
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            DispatchQueue.main.async {
                self.present(alertController, animated: true, completion: nil)
            }
        }
    
    private func webView(_ webView: WKWebView, shouldPreviewElement elementInfo: WKContextMenuElementInfo) -> Bool {
        // Input 요소를 클릭하여 확대가 발생했을 때, 이벤트를 처리
        return false // 확대 막기
    }
}


