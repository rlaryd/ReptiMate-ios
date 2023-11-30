
import UIKit
import Alamofire

protocol toastProtocol {
  func dataSend(data: String)
}

class RegisterViewController : UIViewController {
    let VCfunc : VCfunc = .init()
    var delegate : toastProtocol?
    var verifyCode = ""
    var authBool = false
    var emailSent = false
        
    @IBOutlet weak var backBtn: UIButton!
    
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var authCodeTextField: UITextField!
    @IBOutlet weak var pwdTextField: UITextField!
    @IBOutlet weak var pwdchkTextField: UITextField!
    @IBOutlet weak var nicknameTextField: UITextField!
    
    @IBOutlet weak var emailErrorLabel: UILabel!
    @IBOutlet weak var pwdErrorLabel: UILabel!
    @IBOutlet weak var pwdchkErrorLabel: UILabel!
    @IBOutlet weak var nicknameErrorLabel: UILabel!
    
    @IBOutlet weak var emailsendBtn: UIButton!
    @IBOutlet weak var authCodeBtn: UIButton!
    @IBOutlet weak var nicknameBtn: UIButton!
    @IBOutlet weak var JoinBtn: UIButton!
    
    @IBOutlet weak var radioAllBtn: UIButton!
    @IBOutlet weak var radio1Btn: UIButton!
    @IBOutlet weak var radio2Btn: UIButton!
    @IBOutlet weak var radio3Btn: UIButton!
    
    
    @IBOutlet weak var TermsofUse: UIButton!
    @IBOutlet weak var PrivacyStatement: UIButton!
    @IBOutlet weak var EventandMarketingInformation: UIButton!
    
    var emailerrorheight: NSLayoutConstraint!
    var pwderrorheight: NSLayoutConstraint!
    var pwdchkerrorheight : NSLayoutConstraint!
    var nicknameerrorheight : NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTap()
        self.swipeRecognizer()
        
        // 라디오 체크여부 ui설정
        radioAllBtn.setImage(UIImage(named: "uncheck")?.withTintColor(.mainColor!), for: .normal)
        radioAllBtn.setImage(UIImage(named: "check")?.withTintColor(.mainColor!), for: .selected)
        radio1Btn.setImage(UIImage(named: "uncheck")?.withTintColor(.mainColor!), for: .normal)
        radio1Btn.setImage(UIImage(named: "check")?.withTintColor(.mainColor!), for: .selected)
        radio2Btn.setImage(UIImage(named: "uncheck")?.withTintColor(.mainColor!), for: .normal)
        radio2Btn.setImage(UIImage(named: "check")?.withTintColor(.mainColor!), for: .selected)
        radio3Btn.setImage(UIImage(named: "uncheck")?.withTintColor(.mainColor!), for: .normal)
        radio3Btn.setImage(UIImage(named: "check")?.withTintColor(.mainColor!), for: .selected)
        
        // 텍스트 필드 입력 이벤트 설정
        emailTextField.addTarget(self, action: #selector(textFieldEdited), for: .editingChanged)
        authCodeTextField.addTarget(self, action: #selector(textFieldEdited), for: .editingChanged)
        pwdTextField.addTarget(self, action: #selector(textFieldEdited), for: .editingChanged)
        pwdchkTextField.addTarget(self, action: #selector(textFieldEdited), for: .editingChanged)
        nicknameTextField.addTarget(self, action: #selector(textFieldEdited), for: .editingChanged)
        
        // 비밀번호 입력 textfield *표시
        pwdTextField.textContentType = .newPassword
        pwdchkTextField.textContentType = .newPassword
        pwdTextField.isSecureTextEntry = true
        pwdchkTextField.isSecureTextEntry = true
        
        // 닉네임, 비밀번호, 이메일 유효성 알림 문구
        emailerrorheight = emailErrorLabel.heightAnchor.constraint(equalToConstant: 0)
        pwderrorheight = pwdErrorLabel.heightAnchor.constraint(equalToConstant: 0)
        pwdchkerrorheight = pwdchkErrorLabel.heightAnchor.constraint(equalToConstant: 0)
        nicknameerrorheight = nicknameErrorLabel.heightAnchor.constraint(equalToConstant: 0)
        emailerrorheight.isActive = true
        pwderrorheight.isActive = true
        pwdchkerrorheight.isActive = true
        nicknameerrorheight.isActive = true
        
    }
    
    // =======
    // 버튼 액션
    // =======
    // 인증코드 이메일 발송
    @IBAction func requestEmailAuthCode(_ sender: Any) {
        // 유효 이메일 여부 확인
        if isValidEmail(testStr: emailTextField.text) {
            emailRequest(email: emailTextField.text)
        } else {
            showToast(message: "입력란을 확인해 주세요.", wid: 160)
        }
    }
    
    // 인증코드 일치 확인
    @IBAction func authCodeCheck(_ sender: Any) {
        // 이메일 발송시 리턴으로 이메일 인증코드 변수로 저장 후 입력창에 입력한값과 대조
        if emailSent {
            if  verifyCode == authCodeTextField.text{
                showToast(message: "인증 되었습니다", wid: 130)
                emailTextField.isUserInteractionEnabled = false
                emailTextField.backgroundColor = UIColor.systemGray5
                authCodeTextField.isUserInteractionEnabled = false
                authCodeTextField.backgroundColor = UIColor.systemGray5
                self.authBool = true
                emailsendBtn.isEnabled = false
                authCodeBtn.isEnabled = false
                emailsendBtn.backgroundColor = UIColor.systemGray4
                authCodeBtn.backgroundColor = UIColor.systemGray4
            }
        } else {
            showAlertBox(messageStr: "유효하지 않은 인증 코드입니다.")
        }
        
    }
    // 좌상단 뒤로가기 버튼
    @IBAction func backBtnPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // 회원가입
    @IBAction func Register(_ sender: UIButton) {
        if radio1Btn.isSelected && radio2Btn.isSelected && pwdTextField.text == pwdchkTextField.text && authBool{
            registerRequest(email: emailTextField.text, pw: pwdTextField.text, nickname: nicknameTextField.text, agreeWithMarketing: radio3Btn.isSelected)
        } else {
            showAlertBox(messageStr: "입력란을 확인해 주시기 바랍니다.")
        }
    }
    
    // 동의사항 상세보기
    @IBAction func TermsofUse_Detail(_ sender: UIButton) {
        performSegue(withIdentifier: "TermsofUse", sender: self)
    }
    @IBAction func PrivacyStatement_Detail(_ sender: UIButton) {
        performSegue(withIdentifier: "PrivacyStatement", sender: self)
    }
    @IBAction func EventandMarketingInformation_Detail(_ sender: UIButton) {
        performSegue(withIdentifier: "EventandMarketingInformation", sender: self)
    }
    
    // =======
    // api 요청
    // =======
    // 인증코드 이메일 발송
    func emailRequest(email: Any?) {
        let url = "https://api.reptimate.store/users/email-verify"
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // POST 로 보낼 정보
        let params = ["email": email,   
                      "type": "NEWUSER"] as Dictionary
        // httpBody 에 parameters 추가
        do {
            try request.httpBody = JSONSerialization.data(withJSONObject: params, options: [])
        } catch {
            print("http Body Error")
        }
        
        AF.request(request)
            .responseDecodable(of: emailVerifyResponse.self) { response in
            switch response.result {
            case .success:
                let responseJson = try? JSONEncoder().encode(response.value?.result)
                let resultJson = try? JSONDecoder().decode(emailVerifyCode.self, from: responseJson!)
                let token = resultJson?.signupVerifyToken
                self.verifyCode = token!
                self.showToast(message: "이메일이 발송 되었습니다.", wid: 160)
                self.emailSent = true
                break
                
            case .failure(let error):
                print("Request Error\nCode:\(error._code), Message: \(error.errorDescription!)")
                self.showToast(message: "서버 오류가 발생하였습니다.", wid: 180)
            }
        }
    }
    // 회원가입
    func registerRequest(email: Any?, pw: Any?, nickname: Any?, agreeWithMarketing: Any?) {
            let url = "https://api.reptimate.store/users"
            var request = URLRequest(url: URL(string: url)!)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.timeoutInterval = 10
            
            // POST 로 보낼 정보
            let params = ["email": email,
                          "password": pw,
                          "nickname": nickname,
                          "isPremium": false,
                          "agreeWithMarketing": agreeWithMarketing] as Dictionary
            // httpBody 에 parameters 추가
            do {
                try request.httpBody = JSONSerialization.data(withJSONObject: params, options: [])
            } catch {
                print("http Body Error")
            }
        
        AF.request(request)
            .responseDecodable(of: registerResponse.self) { response in
                switch response.result {
                case .success (let res):
                    if response.value?.status == 200 || response.value?.status == 201 {
                        let responseJson = try? JSONEncoder().encode(response.value?.result)
                        let resultJson = try? JSONDecoder().decode(registerResponseResult.self, from: responseJson!)
                        
                        self.delegate?.dataSend(data: "회원가입이 완료되었습니다.")
                        self.navigationController?.popViewController(animated: true)
                    } else if response.value?.status == 401 || response.value?.statusCode == 401{
                       
                    } else if response.value?.status == 409 {
                        if response.value?.message == "이미 가입된 이메일입니다." {
                            // 입력란 초기화
                            self.showAlertBox(messageStr: "이미 가입된 이메일입니다.")
                            self.emailTextField.text = ""
                            self.authCodeTextField.text = ""
                            self.emailTextField.isUserInteractionEnabled = true
                            self.emailTextField.backgroundColor = UIColor.white
                            self.authCodeTextField.isUserInteractionEnabled = true
                            self.authCodeTextField.backgroundColor = UIColor.white
                            self.authBool = false
                            self.emailsendBtn.isEnabled = true
                            self.authCodeBtn.isEnabled = true
                            self.emailSent = false
                            self.authCodeBtn.backgroundColor = UIColor.systemGreen
                            self.emailsendBtn.backgroundColor = UIColor.systemGreen
                        } else if response.value?.message == "이미 사용중인 닉네임입니다." {
                            self.VCfunc.showAlertAction1(vc: self, preferredStyle: .alert, title: "알림", message: "이미 사용중인 닉네임입니다.")
                            
                        } else {
                            self.showAlertBox(messageStr: "")
                        }
                    } else if response.value?.status == 422 {
                        self.VCfunc.showAlertAction1(vc: self, preferredStyle: .alert, title: "알림", message: "입력란을 다시 확인해 주세요.")
                    }
                    break
                case .failure(let error):
                    print("Request Error\nCode:\(error._code), Message: \(error.errorDescription!)")
                    self.VCfunc.showAlertAction1(vc: self, preferredStyle: .alert, title: "알림", message: "서버와의 통신에 오류가 발생하였습니다.")
                }
                    LoadingService.hideLoading()
            }
        }
    
    // =========
    // 뷰 동적 처리
    // =========
    // 체크박스 선택 이벤트
    // 1 - 이용약관, 2 - 개인정보 취급, 3 - 이벤트 및 마케팅 수신 동의
    @IBAction func radioClick(_ sender: UIButton) {
        if sender == radioAllBtn {
            if radioAllBtn.isSelected {
                if radio1Btn.isSelected && radio2Btn.isSelected && radio3Btn.isSelected{
                    radioAllBtn.isSelected = false
                    radio1Btn.isSelected = false
                    radio2Btn.isSelected = false
                    radio3Btn.isSelected = false
                }
            } else {
                radioAllBtn.isSelected = true
                radio1Btn.isSelected = true
                radio2Btn.isSelected = true
                radio3Btn.isSelected = true
            }
        } else if sender == radio1Btn {
            if radio1Btn.isSelected {
                radio1Btn.isSelected = false
                radioAllBtn.isSelected = false
            } else {
                radio1Btn.isSelected = true
                if radio1Btn.isSelected && radio2Btn.isSelected && radio3Btn.isSelected {
                    radioAllBtn.isSelected = true
                }
            }
        } else if sender == radio2Btn {
            if radio2Btn.isSelected {
                radio2Btn.isSelected = false
                radioAllBtn.isSelected = false
            } else {
                radio2Btn.isSelected = true
                if radio1Btn.isSelected && radio2Btn.isSelected && radio3Btn.isSelected {
                    radioAllBtn.isSelected = true
                }
            }
        } else if sender == radio3Btn {
            if radio3Btn.isSelected {
                radio3Btn.isSelected = false
                radioAllBtn.isSelected = false
            } else {
                radio3Btn.isSelected = true
                if radio1Btn.isSelected && radio2Btn.isSelected && radio3Btn.isSelected {
                    radioAllBtn.isSelected = true
                }
            }
        }
        
    }
    // #selector에서 @objc 가 없으면 호환이 안돼서 붙여줘야함
    //  입력창 에러문구 출력
    @objc func textFieldEdited(textField: UITextField) {
        if textField == emailTextField{
            if isValidEmail(testStr: textField.text) { emailerrorheight.isActive = true
            } else { emailerrorheight.isActive = false
            }
        }
        else if textField == pwdTextField{
            if isValidPassword(pwStr: textField.text) { pwderrorheight.isActive = true
            } else { pwderrorheight.isActive = false
            }
        }
        else if textField == pwdchkTextField{
            if pwdTextField.text == pwdchkTextField.text { pwdchkerrorheight.isActive = true
            } else { pwdchkerrorheight.isActive = false
            }
        }
        else if textField == nicknameTextField{
            if isValidNickname(nicknameStr: textField.text) { nicknameerrorheight.isActive = true
            } else { nicknameerrorheight.isActive = false
            }
        }
        UIView.animate(withDuration: 0.1) { // 효과 주기
            self.view.layoutIfNeeded()
        }
    }
    
    // 이메일, 비밀번호, 닉네임 정규식
    func isValidEmail(testStr: String?) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    func isValidPassword(pwStr: String?) -> Bool{
        let pwdregex = "^(?=.*[A-Za-z])(?=.*[0-9])(?=.*[!@#$%^&*()_+=-]).{8,50}"
        let pwdtest = NSPredicate(format:"SELF MATCHES %@", pwdregex)
        return pwdtest.evaluate(with: pwStr)
    }
    func isValidNickname(nicknameStr : String?) -> Bool{
        let Str = nicknameStr
        let byte = (Str?.utf8)!
        let buffer = [UInt8](byte)
        
        if buffer.count > 18 {
            return false
        } else {
            return true
        }
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
        

    
    
    
    

} // .swift
