

import UIKit
import Alamofire

class FindPWViewController: UIViewController {
    var verifyCode = ""
    var authBool = false
    var emailSent = false
    
    @IBOutlet weak var backBtn: UIButton!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var authCodeTextField: UITextField!
    @IBOutlet weak var pwdTextField: UITextField!
    @IBOutlet weak var pwdchkTextField: UITextField!
    
    @IBOutlet weak var emailErrorLabel: UILabel!
    @IBOutlet weak var pwdErrorLabel: UILabel!
    @IBOutlet weak var pwdchkErrorLabel: UILabel!
    
    @IBOutlet weak var emailsendBtn: UIButton!
    @IBOutlet weak var authCodeBtn: UIButton!
    @IBOutlet weak var FindPWBtn: UIButton!
    
    var emailerrorheight: NSLayoutConstraint!
    var pwderrorheight: NSLayoutConstraint!
    var pwdchkerrorheight : NSLayoutConstraint!
    var nicknameerrorheight : NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTap()
        self.hideKeyboardWhenReturn(emailTextField)
        self.hideKeyboardWhenReturn(authCodeTextField)
        self.hideKeyboardWhenReturn(pwdTextField)
        self.hideKeyboardWhenReturn(pwdchkTextField)
        self.swipeRecognizer()
        
        emailTextField.addTarget(self, action: #selector(textFieldEdited), for: .editingChanged)
        authCodeTextField.addTarget(self, action: #selector(textFieldEdited), for: .editingChanged)
        pwdTextField.addTarget(self, action: #selector(textFieldEdited), for: .editingChanged)
        pwdchkTextField.addTarget(self, action: #selector(textFieldEdited), for: .editingChanged)
        
        emailerrorheight = emailErrorLabel.heightAnchor.constraint(equalToConstant: 0)
        pwderrorheight = pwdErrorLabel.heightAnchor.constraint(equalToConstant: 0)
        pwdchkerrorheight = pwdchkErrorLabel.heightAnchor.constraint(equalToConstant: 0)
        emailerrorheight.isActive = true
        pwderrorheight.isActive = true
        pwdchkerrorheight.isActive = true
    }
    // =======
    // 버튼 액션
    // =======
    // 인증코드 이메일 발송
    @IBAction func requestEmailAuthCode(_ sender: Any) {
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
    @IBAction func FindPW(_ sender: UIButton) {
        
    }
    @IBAction func backBtnPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
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
        let params = ["email": email] as Dictionary
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
                self.showToast(message: "이메일이 발송 되었습니다.", wid: 150)
                self.emailSent = true
                break
                
            case .failure(let error):
                print("Request Error\nCode:\(error._code), Message: \(error.errorDescription!)")
                self.showToast(message: "서버 오류가 발생하였습니다.", wid: 180)
            }
        }
    }
    // 비밀번호 수정
    func FindPWRequest(pw: Any?) {
        let url = "https://api.reptimate.store/users/email-verify"
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // POST 로 보낼 정보
        let params = ["pw": pw] as Dictionary
        // httpBody 에 parameters 추가
        do {
            try request.httpBody = JSONSerialization.data(withJSONObject: params, options: [])
        } catch {
            print("http Body Error")
        }
        
        // 데이터 타입 수정
        AF.request(request)
            .responseDecodable(of: emailVerifyResponse.self) { response in
            switch response.result {
            case .success:
                let responseJson = try? JSONEncoder().encode(response.value?.result)
                let resultJson = try? JSONDecoder().decode(emailVerifyCode.self, from: responseJson!)
                let token = resultJson?.signupVerifyToken
                self.verifyCode = token!
                self.showToast(message: "이메일이 발송 되었습니다.", wid: 150)
                self.emailSent = true
                break
                
            case .failure(let error):
                print("Request Error\nCode:\(error._code), Message: \(error.errorDescription!)")
                self.showToast(message: "서버 오류가 발생하였습니다.", wid: 180)
            }
        }
    }
    @objc func textFieldEdited(textField: UITextField) {
        if textField == emailTextField{
            if isValidEmail(testStr: textField.text) {
                emailerrorheight.isActive = true
            } else {
                emailerrorheight.isActive = false
            }
        }
        else if textField == pwdTextField{
            if isValidPassword(pwStr: textField.text) {
                pwderrorheight.isActive = true
            } else {
                pwderrorheight.isActive = false
            }
        }
        else if textField == pwdchkTextField{
            if pwdTextField.text == pwdchkTextField.text {
                pwdchkerrorheight.isActive = true
            } else {
                pwdchkerrorheight.isActive = false
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
    
} // .SWIFT
