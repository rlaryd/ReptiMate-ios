//
//  auctionHomeViewController.swift
//  ReptiMate
//
//  Created by 김기용 on 2023/06/27.
//

import UIKit
import Alamofire
import WebKit

class auctionHomeViewController: UIViewController, WKScriptMessageHandler {
    
    let VCfunc: VCfunc = .init()
    
    var refreshToken = ""
    var accessToken = ""
    var idx = ""
    var nickname = ""
    var profilePath = ""
    
    var cookieValue: Any? = nil
    var cookieString = ""
    var jsonObject = [String: String]()
    
    var delegateData = ""
    
    @IBOutlet weak var webView: WKWebView!
    
    
    @IBOutlet weak var viewGroup: UIView!
    var auctionWebView = WKWebView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
                userContentController.add(self, name: "openNativeActivity")
                
                let configuration = WKWebViewConfiguration()
                configuration.userContentController = userContentController
                configuration.defaultWebpagePreferences = preferences
                configuration.allowsInlineMediaPlayback = true
                
                let uctionWebView = WKWebView(frame: self.viewGroup.bounds, configuration: configuration)
                uctionWebView.scrollView.bounces = true
                uctionWebView.navigationDelegate = self
                uctionWebView.uiDelegate = self
                uctionWebView.autoresizingMask = [.flexibleWidth, . flexibleHeight]
                uctionWebView.scrollView.showsVerticalScrollIndicator = false
                uctionWebView.scrollView.showsHorizontalScrollIndicator = false
                uctionWebView.allowsBackForwardNavigationGestures = true
                
                uctionWebView.configuration.websiteDataStore.httpCookieStore.setCookie(cookie) {
                   // 쿠키 등록 완료 후 처리
                    self.viewGroup.addSubview(uctionWebView)
                    print("쿠키등록 -> 웹뷰 로드")
                    if let url = URL(string: "https://web.reptimate.store/auction") {
                        let request = URLRequest(url: url)
                        uctionWebView.load(request)
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
        if message.name == "openNativeActivity"{
            
            print("openNativeActivity: 수령, message  :  ")
            print(message.body)
            if let jsonData = message.body as? [String: Any],
               let idx = jsonData["idx"] as? String,
               let streamkey = jsonData["streamKey"] as? String {
                
                print("idx: \(idx), streamkey: \(streamkey)")
                
                // 다른 뷰 컨트롤러로 데이터 전달
                guard let StreamerViewController = self.storyboard?.instantiateViewController(withIdentifier: "StreamerViewController") as? StreamerViewController  else { return }
                // 회원가입 완료시 토스트 메시지 위한 delegate
                StreamerViewController.boardIdx = idx
                StreamerViewController.streamKey = streamkey
                self.navigationController?.pushViewController(StreamerViewController, animated: true)
            }
        }
    }
    
    
    

}


//auctionHomeViewController
extension auctionHomeViewController: WKNavigationDelegate {
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
    
        print("\(navigationAction.request.url?.absoluteString ?? "")" )
        
        decisionHandler(.allow)
    }
}

extension auctionHomeViewController: WKUIDelegate {

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

