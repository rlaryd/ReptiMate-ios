

import UIKit
import Alamofire

import GoogleSignIn
import FirebaseAuth
import FirebaseCore
import KakaoSDKCommon
import KakaoSDKAuth
import KakaoSDKUser
import AuthenticationServices


class LoginViewController: UIViewController, toastProtocol, UINavigationControllerDelegate, ASAuthorizationControllerPresentationContextProviding, ASAuthorizationControllerDelegate {
    
    var msgfromRVC : String = ""
    
    var email: String?
    var nickName: String?
    var socialToken: String?
    var fcmToken: String?
    
    @IBOutlet weak var LoginBtn: UIButton!
    
    @IBOutlet weak var RegisterBtn: UIButton!
    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var pwdTextField: UITextField!
    
    @IBOutlet weak var FindPWBtn: UIButton!
    
    @IBOutlet weak var googleSignInButton: UIButton!
    @IBOutlet weak var kakaoLoginBtn: UIButton!
    @IBOutlet weak var GSIBtn: GIDSignInButton!
    
    @IBOutlet weak var appleLoginBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        idTextField.addLeftPadding()
        pwdTextField.addLeftPadding()
        
//        pwdTextField.textContentType = .newPassword
        pwdTextField.isSecureTextEntry = true
        
        //googleSignInButton.style = .wide
        //googleSignInButton.layer.shadowColor = UIColor.white.cgColor
        googleSignInButton.addTarget(self, action: #selector(handleGoogleLogin), for: .touchUpInside)
        appleLoginBtn.addTarget(self, action: #selector(appleLogin), for: .touchUpInside)
        
        appleLoginBtn.cornerRadius = 5
        kakaoLoginBtn.cornerRadius = 5
        googleSignInButton.cornerRadius = 5
        
        appleLoginBtn.layer.shadowColor = UIColor.lightGray.cgColor
        kakaoLoginBtn.layer.shadowColor = UIColor.lightGray.cgColor
        googleSignInButton.layer.shadowColor = UIColor.lightGray.cgColor
        
        appleLoginBtn.layer.shadowOffset = CGSize(width: 1, height: 1)
        kakaoLoginBtn.layer.shadowOffset = CGSize(width: 1, height: 1)
        googleSignInButton.layer.shadowOffset = CGSize(width: 1, height: 1)
        
        self.hideKeyboardWhenTap()
        self.hideKeyboardWhenReturn(idTextField)
        self.hideKeyboardWhenReturn(pwdTextField)
        

        if let fcm = UserDefaults.standard.string(forKey: "fcmToken") {
            fcmToken = fcm
            print("LoginViewController의 fcm. :  ", fcmToken)
        }
        
        if  (UserDefaults.standard.string(forKey: "accessToken") != nil){
            
            
            
            guard let LoginViewController = self.storyboard?.instantiateViewController(withIdentifier: "TabBarController") else { return }
            self.navigationController?.pushViewController(LoginViewController, animated: true)
        }
        
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        idTextField.text = ""
        pwdTextField.text = ""
    }
    
    func dataSend(data: String) {
        if data.lengthOfBytes(using: String.Encoding.utf8) > 0 {
            self.showToast(message: data, wid: 200)
        }
    }
    // =======
    // 버튼 액션
    // =======
    @IBAction func login(_ sender: UIButton) {
        guard let id = idTextField.text, id != "", let pwd = pwdTextField.text, pwd != "" else {
            return
        }
        loginRequest(email: idTextField.text, pw: pwdTextField.text, fcmToken: fcmToken)
    }
    // 회원가입
    @IBAction func register(_ sender: UIButton) {
        guard let LoginViewController = self.storyboard?.instantiateViewController(withIdentifier: "RegisterViewController") as? RegisterViewController  else { return }
        // 회원가입 완료시 토스트 메시지 위한 delegate
        LoginViewController.delegate = self
        self.navigationController?.pushViewController(LoginViewController, animated: true)
    }
    
    @IBAction func FindPW(_ sender: UIButton) {
        guard let LoginViewController = self.storyboard?.instantiateViewController(withIdentifier: "FindPWViewController") else { return }
        self.navigationController?.pushViewController(LoginViewController, animated: true)
    }
    @IBAction func kakaoLogin(_ sender: Any) {
        if (UserApi.isKakaoTalkLoginAvailable()) {
            UserApi.shared.loginWithKakaoTalk {(oauthToken, error) in
                if let error = error {
                    print(error)
                }
                else {
                    print("loginWithKakaoTalk() success.")

                    //do something
                    _ = oauthToken
                    
                    let kakaoToken = oauthToken?.accessToken
                    print(kakaoToken)
                    UserApi.shared.me { [self] user, error in
                        if let error = error {
                            print(error)
                        } else {
                            guard let token = oauthToken?.accessToken, let email = user?.kakaoAccount?.email,
                                  let name = user?.kakaoAccount?.profile?.nickname else{
                                      print("token/email/name is nil")
                                      return
                                  }
                            self.email = email
                            self.nickName = name
                            self.socialToken = token
                            //서버에 이메일/토큰/이름 보내주기
                            socialLoginRequest(socialType: "KAKAO", acessToken: socialToken!, email: self.email!, nickName: nickName!, fcmToken: fcmToken)
                            
                        }
                    }
                }
            }
        }
    }
    @objc func handleGoogleLogin() {
        print("")
        print("google login pressed")
        print("")
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }

        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [weak self] signInResult, _ in
            guard let self,
                    let result = signInResult,
                    let email = result.user.profile?.email,
                    let nickName = result.user.profile?.name,
                    let token = result.user.idToken?.tokenString else { return }
            
            
            // 서버에 토큰을 보내기. 이 때 idToken, accessToken 차이에 주의할 것
            self.socialLoginRequest(socialType: "GOOGLE", acessToken: token, email: email, nickName: nickName, fcmToken: self.fcmToken)
        }
    }
    @IBAction func appleLogin(_ sender: Any) {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email]
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.presentationContextProvider = self
            authorizationController.performRequests()
    }
    
    
    // =======
    // api 요청
    // =======
    // 로그인
    func loginRequest(email: String?, pw: String?, fcmToken: String?) {

        let url = "https://api.reptimate.store/auth"
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let fcm = UserDefaults.standard.string(forKey: "fcmToken") {
            print("loginRequest  :  fcm  :  ", fcm)
            let params = ["email": email,
                          "fbToken": fcm,
                          "password": pw] as Dictionary

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
                        print(response)
                        var statusCode = (response.response?.statusCode)!
                        print(statusCode)
                        if response.value?.status == 201 {
                            let responseJson = try? JSONEncoder().encode(response.value?.result)
                            let resultJson = try? JSONDecoder().decode(loginResponseResult.self, from: responseJson!)
                            let token = resultJson?.accessToken
                            let refreshtoken = resultJson?.refreshToken
                            print(token as Any)
                            UserDefaults.standard.set(token, forKey: "accessToken")
                            UserDefaults.standard.set(refreshtoken, forKey: "refreshToken")
                            
                            guard let LoginViewController = self.storyboard?.instantiateViewController(withIdentifier: "TabBarController") else { return }
                            self.navigationController?.pushViewController(LoginViewController, animated: true)
                        } else if response.value?.status == 422 {
                            self.showAlertBox(messageStr: "이메일 또는 비밀번호가 올바르지 않습니다.")
                        } else {
                            self.showToast(message: "서버와의 통신에 오류가 발생하였습니다.", wid: 180)
                        }
                    break
                case .failure(let error):
                    print("Request Error\nCode:\(error._code), Message: \(error.errorDescription!)")
                    self.showToast(message: "서버와의 통신에 오류가 발생하였습니다.", wid: 180)
                }
            }
        }
        

    }
    // 소셜로그인
    func socialLoginRequest(socialType: String, acessToken: String, email: String, nickName: String, fcmToken: Any?) {
        let url = "https://api.reptimate.store/auth/social"
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let fcm = UserDefaults.standard.string(forKey: "fcmToken") {
            print("")
            // POST 로 보낼 정보
            let params = [ "accessToken": acessToken,
                           "socialType": socialType,
                           "fbToken": fcm,
                           "email": email,
                          "nickname": nickName] as Dictionary

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
                    let statusCode = (response.response?.statusCode)!
                    print(statusCode)
                    print(response)
                    if statusCode == 201 {
                        let responseJson = try? JSONEncoder().encode(response.value?.result)
                        let resultJson = try? JSONDecoder().decode(loginResponseResult.self, from: responseJson!)
                        let token = resultJson?.accessToken
                        print(token as Any)
                        UserDefaults.standard.set(token, forKey: "accessToken")
                        let refreshtoken = resultJson?.refreshToken
                        UserDefaults.standard.set(refreshtoken, forKey: "refreshToken")
                        guard let LoginViewController = self.storyboard?.instantiateViewController(withIdentifier: "TabBarController") else { return }
                        self.navigationController?.pushViewController(LoginViewController, animated: true)
                    } else {
                        self.showAlertBox(messageStr: "서버와의 통신에 오류가 발생하였습니다.")
                    }
                    break
                    
                case .failure(let error):
                    print("Request Error\nCode:\(error._code), Message: \(error.errorDescription!)")
                    self.showToast(message: "서버와의 통신에 오류가 발생하였습니다.", wid: 180)
                }
            }
        }
        

    }
    
    // 이메일 정규식
    func isValidEmail(testStr: String?) -> Bool {
           
             let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
             let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
             return emailTest.evaluate(with: testStr)
              }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    // AlertBox 출력
    func showAlertBox(messageStr: String?) {
          let alert = UIAlertController(title: "알림", message: messageStr, preferredStyle: .alert)
              let check = UIAlertAction(title: "확인", style: .destructive, handler: nil)
              alert.addAction(check)
              present(alert, animated: true, completion: nil)
    }
    
    // 토스트 메시지 출력
    func showToast(message : String, font: UIFont = UIFont.systemFont(ofSize: 14.0), wid: Int) {
        let toastLabel = UILabel(frame: CGRect(x: Int(self.view.frame.size.width)/2 - wid/2, y: Int(self.view.frame.size.height)-100, width: wid, height: 35))
            toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            toastLabel.textColor = UIColor.white
            toastLabel.font = font
            toastLabel.textAlignment = .center;
            toastLabel.text = message
            toastLabel.alpha = 1.0
            toastLabel.layer.cornerRadius = 10;
            toastLabel.clipsToBounds  =  true
            self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 1.8, delay: 0.1, animations: {
                 toastLabel.alpha = 0.0
            }, completion: {(isCompleted) in
                toastLabel.removeFromSuperview()
            })
        }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    // Apple ID 연동 성공 시
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        // Apple ID
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
                
            // 계정 정보 가져오기
            let userIdentifier = appleIDCredential.user
            let fullName = appleIDCredential.fullName
            if let email = appleIDCredential.email {
                
                        print("이메일 : \(email)")
                let tokenString = String(data: appleIDCredential.identityToken ?? Data(), encoding: .utf8)!
                socialLoginRequest(socialType: "APPLE", acessToken: tokenString, email: email, nickName: "\((fullName?.givenName ?? "") + (fullName?.familyName ?? ""))", fcmToken: fcmToken)
                    }
                    // 두번째부터는 credential.email은 nil이고, credential.identityToken에 들어있다.
                    else {
                        // credential.identityToken은 jwt로 되어있고, 해당 토큰을 decode 후 email에 접근해야한다.
                        if let tokenString = String(data: appleIDCredential.identityToken ?? Data(), encoding: .utf8) {
                            let email2 = Utils.decode(jwtToken: tokenString)["email"] as? String ?? ""
                            print("이메일 - \(email2)")
                            socialLoginRequest(socialType: "APPLE", acessToken: tokenString, email: email2, nickName: "\((fullName?.givenName ?? "") + (fullName?.familyName ?? ""))", fcmToken: fcmToken)
                        }
                    }
                
            print("User ID : \(userIdentifier)")
            print("User Name : \((fullName?.givenName ?? "") + (fullName?.familyName ?? ""))")
            
            

        default:
            break
        }
    }
        
    // Apple ID 연동 실패 시
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
    }
    
    
}



