

import Foundation
import UIKit
import Alamofire


class VCfunc : UIViewController {
    
    func getAccessToken(completion: @escaping () -> Void) {
        if let accessToken = UserDefaults.standard.string(forKey: "accessToken") {
            if let refreshToken = UserDefaults.standard.string(forKey: "refreshToken") {
                let url = "https://api.reptimate.store/auth/token"
                var request = URLRequest(url: URL(string: url)!)
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.addValue("Bearer "+accessToken , forHTTPHeaderField: "Authorization")
                request.httpMethod = "POST"
                // POST 로 보낼 정보
                let params = ["refreshToken": refreshToken] as Dictionary
                // httpBody 에 parameters 추가
                do {
                    try request.httpBody = JSONSerialization.data(withJSONObject: params, options: [])
                } catch {
                    print("http Body Error")
                }
                AF.request(request)
                    .responseDecodable(of: loginResponse.self) { response in
                    switch response.result {
                    case .success:
                        if response.value?.status == 201 || response.value?.statusCode == 201 {
                            print("========================================")
                            print("accessTocken 만료되어 재발급 진행")
                            print("========================================")
                            let responseJson = try? JSONEncoder().encode(response.value?.result)
                            let resultJson = try? JSONDecoder().decode(loginResponseResult.self, from: responseJson!)
                            let token = resultJson?.accessToken
                            DispatchQueue.main.async {
                                UserDefaults.standard.removeObject(forKey: "accessToken")
                                UserDefaults.standard.synchronize()
                                UserDefaults.standard.set(token, forKey: "accessToken")
                                UserDefaults.standard.synchronize()
                                completion()
                            }
                        } else {
                            completion()
                            self.showAlertAction1(vc: self, preferredStyle: .alert, title: "로그인 만료", message: "다시 로그인 해주시기 바랍니다.")
                            UserDefaults.standard.removeObject(forKey: "accessToken")
                            UserDefaults.standard.removeObject(forKey: "refreshToken")
                            UserDefaults.standard.synchronize()
                            if let navigationController = self.navigationController {
                                navigationController.popToRootViewController(animated: true)
                            }
                        }
                        break
                    case .failure(let error):
                        print("Request Error\nCode:\(error._code), Message: \(error.errorDescription!)")
                        self.showToast(message: "서버 오류가 발생하였습니다.", wid: 180)
                        completion()
                    }
                        
                }
            }
        }
        
//        var accessToken = UserDefaults.standard.string(forKey: "accessToken")!
//        var refreshToken = UserDefaults.standard.string(forKey: "refreshToken")!
        
        
    }
    
    
    func showAlertAction1(vc: UIViewController? = UIApplication.shared.keyWindow?.visibleViewController, preferredStyle: UIAlertController.Style = .alert, title: String = "", message: String = "", completeTitle: String = "확인", _ completeHandler:(() -> Void)? = nil){
                
                guard let currentVc = vc else {
                    completeHandler?()
                    return
                }
                
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
                    
                    let completeAction = UIAlertAction(title: completeTitle, style: .default) { action in
                        completeHandler?()
                    }
                    
                    alert.addAction(completeAction)
                    
                    currentVc.present(alert, animated: true, completion: nil)
                }
    }
    /**
             # showAlertAction2
             - Author: suni
             - Date:
             - Parameters:
                - vc: 알럿을 띄울 뷰컨트롤러
                - preferredStyle: 알럿 스타일
                - title: 알럿 타이틀명
                - message: 알럿 메시지
                - cancelTitle: 취소 버튼명
                - completeTitle: 확인 버튼명
                - cancelHandler: 취소 버튼 클릭 시, 실행될 클로저
                - completeHandler: 확인 버튼 클릭 시, 실행될 클로저
             - Returns:
             - Note: 버튼이 2개인 알럿을 띄우는 함수
            */
        func showAlertAction2(vc: UIViewController? = UIApplication.shared.keyWindow?.visibleViewController, preferredStyle: UIAlertController.Style = .alert, title: String = "", message: String = "", cancelTitle: String = "취소", completeTitle: String = "확인",  _ cancelHandler: (() -> Void)? = nil, _ completeHandler: (() -> Void)? = nil){
                
                guard let currentVc = vc else {
                    completeHandler?()
                    return
                }
                
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
                    
                    let cancelAction = UIAlertAction(title: cancelTitle, style: .cancel) { action in
                        cancelHandler?()
                    }
                    let completeAction = UIAlertAction(title: completeTitle, style: .default) { action in
                        completeHandler?()
                    }
                    
                    alert.addAction(cancelAction)
                    alert.addAction(completeAction)
                    
                    currentVc.present(alert, animated: true, completion: nil)
                }
            }
            
            /**
             # showAlertAction3
             - Parameters:
                - vc: 알럿을 띄울 뷰컨트롤러
                - preferredStyle: 알럿 스타일
                - title: 알럿 타이틀명
                - message: 알럿 메시지
                - cancelTitle: 취소 버튼명
                - completeTitle: 확인 버튼명
                - destructiveTitle: 삭제 버튼명
                - cancelHandler: 취소 버튼 클릭 시, 실행될 클로저
                - completeHandler: 확인 버튼 클릭 시, 실행될 클로저
                - destructiveHandler: 삭제 버튼 클릭 시, 실행될 클로저
             - Returns:
             - Note: 버튼이 3개인 알럿을 띄우는 함수
            */
            static func showAlertAction3(vc: UIViewController? = UIApplication.shared.keyWindow?.visibleViewController, preferredStyle: UIAlertController.Style = .alert, title: String = "", message: String = "", cancelTitle: String = "취소", completeTitle: String = "확인", destructiveTitle: String = "삭제", _ cancelHandler:(() -> Void)? = nil, _ completeHandler:(() -> Void)? = nil, _ destructiveHandler:(() -> Void)? = nil){
                
                guard let currentVc = vc else {
                    completeHandler?()
                    return
                }
                
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
                    
                    let cancelAction = UIAlertAction(title: cancelTitle, style: .cancel) { action in
                        cancelHandler?()
                    }
                    let destructiveAction = UIAlertAction(title: destructiveTitle, style: .destructive) { action in
                        cancelHandler?()
                    }
                    let completeAction = UIAlertAction(title: completeTitle, style: .default) { action in
                        completeHandler?()
                    }
                    
                    alert.addAction(cancelAction)
                    alert.addAction(destructiveAction)
                    alert.addAction(completeAction)
                    
                    currentVc.present(alert, animated: true, completion: nil)
                }
            }
    static func showAlertActionMD(vc: UIViewController? = UIApplication.shared.keyWindow?.visibleViewController, preferredStyle: UIAlertController.Style = .alert, title: String = "", message: String = "", cancelTitle: String = "취소", completeTitle: String = "수정", destructiveTitle: String = "삭제", _ cancelHandler:(() -> Void)? = nil, _ completeHandler:(() -> Void)? = nil, _ destructiveHandler:(() -> Void)? = nil){
        
        guard let currentVc = vc else {
            completeHandler?()
            return
        }
        
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
            
            let cancelAction = UIAlertAction(title: cancelTitle, style: .cancel) { action in
                cancelHandler?()
            }
            let destructiveAction = UIAlertAction(title: destructiveTitle, style: .destructive) { action in
                cancelHandler?()
            }
            let completeAction = UIAlertAction(title: completeTitle, style: .default) { action in
                completeHandler?()
            }
            
            alert.addAction(cancelAction)
            alert.addAction(destructiveAction)
            alert.addAction(completeAction)
            
            currentVc.present(alert, animated: true, completion: nil)
        }
    }
    // AlertBox 출력\\
    func showAlertBox(_ messageStr : String, completion : (()->Void)? = nil) {
            
            // 메인 스레드에서 실행하도록 변경
            DispatchQueue.main.async {
                let alert = UIAlertController(title: nil, message: messageStr, preferredStyle: .alert)
                
                let okAction = UIAlertAction(title: "확인", style: .cancel) { (_) in
                    completion?()
                    
                }
                alert.addAction(okAction)
                self.present(alert, animated: false, completion: nil)
                
            }
        }

    // 토스트 메시지 출력
    public func showToast(message : String, font: UIFont = UIFont.systemFont(ofSize: 14.0), wid: Int) {
        let toastLabel = UILabel(frame: CGRect(x: Int(self.view.frame.size.width)/2 - wid/2, y: Int(self.view.frame.size.height)-100, width: wid, height: 35))
            toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            toastLabel.textColor = UIColor.white
            toastLabel.font = font
            toastLabel.textAlignment = .center;
            toastLabel.text = message
            toastLabel.alpha = 1.0
            toastLabel.layer.cornerRadius = 10;
            toastLabel.clipsToBounds  =  true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1){
            self.view.addSubview(toastLabel)
            UIView.animate(withDuration: 1.8, delay: 0.1, animations: {
                 toastLabel.alpha = 0.0
            }, completion: {(isCompleted) in
                toastLabel.removeFromSuperview()
            })
        }
       
    }
    
}

// uibutton extension
// 버튼 익스텐션
extension UIButton {
    func setBackgroundColor(_ color: UIColor, for state: UIControl.State) {
        UIGraphicsBeginImageContext(CGSize(width: 1.0, height: 1.0))
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.setFillColor(color.cgColor)
        context.fill(CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0))
        
        let backgroundImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
         
        self.setBackgroundImage(backgroundImage, for: state)
    }
}

