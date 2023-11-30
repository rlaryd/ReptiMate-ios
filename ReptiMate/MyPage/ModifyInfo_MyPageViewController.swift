

import UIKit
import Alamofire
import BSImagePicker
import PhotosUI

class ModifyInfo_MyPageViewController: UIViewController {
    
    let VCfunc: VCfunc = .init()
    
    let ACTIVITY_NAME = "ModifyInfo_MyPageViewController"
    
    // 화면 내 활동 데이터 변수
    var userName = ""
    var userEmail = ""
    var accessToken = ""
    
    // 회원정보 수신 데이터 변수
    var idx = ""
    var profilePath = ""
    var isPremium = ""
    var agreeWithMarketing = ""
    var createdAt = ""
    var loginMethod = ""
    
    var verifyCode = "" // 이메일 인증 코드
    var emailSent = false
    var authBool = false
    
    var nicknameChanged = false
    var emailChanged = false
    
    var selectedImage: UIImage? = nil
    
    @IBOutlet weak var profileImgIV: UIImageView!
    
    @IBOutlet weak var backBtn: UIButton!
    
    
    @IBOutlet weak var finishModifyBtn: UIButton!
    @IBOutlet weak var nicknameChangeBtn: UIButton!
    @IBOutlet weak var emailSendBtn: UIButton!
    @IBOutlet weak var emailAuthCodeBtn: UIButton!
    @IBOutlet weak var pwBtn: UIButton!
    @IBOutlet weak var pwChangeBtn: UIButton!
    @IBOutlet weak var pwChangecencelBtn: UIButton!
    
    @IBOutlet weak var nicknameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var authCodeTextField: UITextField!
    @IBOutlet weak var pastPwTextField: UITextField!
    @IBOutlet weak var changePwTextField: UITextField!
    @IBOutlet weak var checkPwTextField: UITextField!
    
    @IBOutlet weak var authCodeStackView: UIStackView!
    @IBOutlet weak var pwChangeStackView: UIStackView!
    
    @IBOutlet weak var pwdErrorLabel: UILabel!
    @IBOutlet weak var socialErrorLabel: UILabel!
    
    var authCodeSVHeight: NSLayoutConstraint!
    var pwChangeSVHeight: NSLayoutConstraint!
    var pwBtnHeight : NSLayoutConstraint!
    
    var pwderrorheight: NSLayoutConstraint!
    var socialErrorLabelheight: NSLayoutConstraint!
    
    let imagePickerController = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.swipeRecognizer()
        self.hideKeyboardWhenTap()
        
        accessToken = UserDefaults.standard.string(forKey: "accessToken")!
        print("토큰 받아보기 :",accessToken)
        
        profileImgIV.layer.cornerRadius = profileImgIV.frame.height/2
        profileImgIV.layer.borderWidth = 1
        profileImgIV.layer.borderColor = UIColor.clear.cgColor
        profileImgIV.clipsToBounds = true

        let buyPoint = UITapGestureRecognizer(target: self, action: #selector(movetoPhotoLibrary))
        profileImgIV.isUserInteractionEnabled = true
        profileImgIV.addGestureRecognizer(buyPoint)
        
        pwChangeStackView.isHidden = true
        authCodeStackView.isHidden = true
        
        changePwTextField.addTarget(self, action: #selector(textFieldEdited), for: .editingChanged)
        pwderrorheight = pwdErrorLabel.heightAnchor.constraint(equalToConstant: 0)
        pwderrorheight.isActive = true
        socialErrorLabelheight = socialErrorLabel.heightAnchor.constraint(equalToConstant: 0)
        socialErrorLabelheight.isActive = true
        
        pastPwTextField.textContentType = .newPassword
        changePwTextField.textContentType = .newPassword
        checkPwTextField.textContentType = .newPassword
        pastPwTextField.isSecureTextEntry = true
        changePwTextField.isSecureTextEntry = true
        checkPwTextField.isSecureTextEntry = true
        
        userInfoRequest(token: accessToken)
    }
    
    
    // =======
    // 뷰 클릭 이벤트
    // =======
    
    // 회원정보 수정
    @IBAction func modifyUserInfo(_ sender: Any) {
        LoadingService.showLoading()
        if userName != nicknameTextField.text && nicknameChanged == false{
            self.VCfunc.showAlertAction1(vc: self, preferredStyle: .alert, title: "알림", message: "닉네임 중복을 확인해 주세요")
        } else if userEmail != emailTextField.text && authBool == false{
            self.VCfunc.showAlertAction1(vc: self, preferredStyle: .alert, title: "알림", message: "이메일 인증을 진행해 주세요")
        } else if nicknameChanged == false && authBool == false && selectedImage == nil{
            self.navigationController?.popViewController(animated: true)
        } else {
            modifyRequest(email: emailTextField.text, nickname: nicknameTextField.text, token: accessToken, imageData: selectedImage)
        }
    }
    // 닉네임 중복검사
    @IBAction func duplicateNickname(_ sender: Any) {
        LoadingService.showLoading()
        nicknameDuplicateRequest(nickname: nicknameTextField.text, token: accessToken)
    }
    // 인증 메일 발송
    @IBAction func emailSend(_ sender: Any) {
        LoadingService.showLoading()
        authCodeStackView.isHidden = !authCodeStackView.isHidden
        emailRequest(email: emailTextField.text)
    }
    // 이메일 인증
    @IBAction func verifyEmailCode(_ sender: Any) {
        LoadingService.showLoading()
        // 인증코드가 일치 한다면 인증코드 입력창 닫기, 메시지 출력, 입력창 막기
        if emailSent {
            if  verifyCode == authCodeTextField.text{
                VCfunc.showAlertAction1(vc: self, preferredStyle: .alert, title: "알림", message: "이메일 인증이 완료되었습니다.")
                // 이메일 인증 후 뷰 처리
                emailTextField.isUserInteractionEnabled = false
                emailTextField.backgroundColor = UIColor.systemGray5
                authCodeTextField.isUserInteractionEnabled = false
                authCodeTextField.backgroundColor = UIColor.systemGray5
                emailSendBtn.isEnabled = false
                emailAuthCodeBtn.isEnabled = false
                emailSendBtn.backgroundColor = UIColor.systemGray4
                emailAuthCodeBtn.backgroundColor = UIColor.systemGray4
                authCodeStackView.isHidden = !authCodeStackView.isHidden
                
                self.authBool = true
            }
        } else {
            VCfunc.showAlertAction1(vc: self, preferredStyle: .alert, title: "알림", message: "유효하지 않은 인증코드 입니다.")
        }
        
    }
    // 비밀번호 변경란 활성화
    @IBAction func activePwChange(_ sender: Any) {
        pwChangeStackView.isHidden = !pwChangeStackView.isHidden
        pwBtn.isHidden = true
    }
    // 비밀번호 변경
    @IBAction func changePw(_ sender: Any) {
        LoadingService.showLoading()
        if isValidPassword(pwStr: checkPwTextField.text){
            if changePwTextField.text == checkPwTextField.text {
                pwChangeRequest(currentPassword: pastPwTextField.text, newPassword: changePwTextField.text, token: accessToken)
                
            } else {
                VCfunc.showAlertAction1(vc: self, preferredStyle: .alert, title: "알림", message: "새 비밀번호가 일치하지 않습니다.")
            }
        } else {
            VCfunc.showAlertAction1(vc: self, preferredStyle: .alert, title: "알림", message: "입력란을 확인해 주시기 바랍니다.")
        }
    }
    @IBAction func pwChangecencel(_ sender: Any) {
        pastPwTextField.text = ""
        checkPwTextField.text = ""
        changePwTextField.text = ""
        self.pwBtn.isHidden = false
        self.pwChangeStackView.isHidden = !self.pwChangeStackView.isHidden
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    
    // =======
    // api 요청
    // =======
    // 닉네임 중복검사 요청
    func nicknameDuplicateRequest(nickname: String?, token: String?) {
        let url = "https://api.reptimate.store/users/nickname"
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer "+token! , forHTTPHeaderField: "Authorization")
        
        // POST 로 보낼 정보
        let params = ["nickname": nickname] as Dictionary

        // httpBody 에 parameters 추가
        do {
            try request.httpBody = JSONSerialization.data(withJSONObject: params, options: [])
        } catch {
            print("http Body Error")
        }
        AF.request(request)
            .validate(statusCode: 200..<500)
            .responseDecodable(of: messageResponse.self) { response in
            switch response.result {
            case .success:
               print(response)
                if response.value?.status == 200 {
                    self.VCfunc.showAlertAction1(vc: self, preferredStyle: .alert, title: "알림", message: "사용 가능한 닉네임 입니다.")
                    self.nicknameChanged = true
                } else if response.value?.status == 401 || response.value?.statusCode == 401{
                   self.VCfunc.getAccessToken {
                      let newAccessToken = UserDefaults.standard.string(forKey: "accessToken")
                      if newAccessToken != token {
                         self.accessToken = UserDefaults.standard.string(forKey: "accessToken")!
                         self.nicknameDuplicateRequest(nickname: nickname, token: newAccessToken)
                      } else {
                         self.VCfunc.showAlertAction1(vc: self, preferredStyle: .alert, title: "로그인 만료", message: "다시 로그인 해주시기 바랍니다.")
                         if let navigationController = self.navigationController {
                             navigationController.popToRootViewController(animated: true)
                         }
                      }
                   }
                   
                } else if response.value?.status == 409 {
                    self.VCfunc.showAlertAction1(vc: self, preferredStyle: .alert, title: "알림", message: "이미 사용중인 닉네임 입니다.")
                } else if response.value?.status == 422 {
                    self.VCfunc.showAlertAction1(vc: self, preferredStyle: .alert, title: "알림", message: "입력란을 다시 확인해 주세요.")
                }
            case .failure(let error):
                print("Request Error\nCode:\(error._code), Message: \(error.errorDescription!)")
                self.VCfunc.showToast(message: "서버 오류가 발생하였습니다.", wid: 180)
            }
            LoadingService.hideLoading()
        }
    }
    // 회원정보 불러오기
    func userInfoRequest(token: String?) {
        let url = "https://api.reptimate.store/users/me"
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer "+token! , forHTTPHeaderField: "Authorization")
        // POST 로 보낼 정보
        AF.request(url,
                method: .get,
                parameters: nil,
                encoding: URLEncoding.default,
                   headers: ["Content-Type":"application/json", "Accept":"application/json", "Authorization":"Bearer "+token!])
            .responseDecodable(of: userInfoResponse.self) { response in
            switch response.result {
            case .success (let res):
               if response.value?.status == 200 {
                  let responseJson = try? JSONEncoder().encode(res.result)
                  let resultJson = try? JSONDecoder().decode(userResponseResult.self, from: responseJson!)

                  self.userName = resultJson?.nickname ?? ""
                  self.userEmail = resultJson?.email ?? ""
                  self.nicknameTextField.text = self.userName
                  self.emailTextField.text = self.userEmail
                  
                  if resultJson?.loginMethod != nil {
                      self.emailSendBtn.isEnabled = false
                      self.pwBtn.isEnabled = false
                      self.socialErrorLabelheight.isActive = false
                      self.emailTextField.isUserInteractionEnabled = false
                      self.emailTextField.backgroundColor = UIColor.systemGray5
                      self.emailSendBtn.backgroundColor = UIColor.systemGray4
                      self.emailSendBtn.borderColor = UIColor.systemGray4
                      
                      self.pwBtn.backgroundColor = UIColor.systemGray4
                      self.pwBtn.borderColor = UIColor.systemGray4
                  }
                  if ((resultJson?.profilePath) != nil) {
                      // 이미지 경로 URL 생성
                      let imageURL = URL(string: (resultJson?.profilePath)!)
                      // URL을 통해 이미지 다운로드
                      if let url = imageURL {
                          DispatchQueue.global(qos: .userInitiated).async {
                              if let imageData = try? Data(contentsOf: url) {
                                  DispatchQueue.main.async {
                                      // 이미지 다운로드가 완료된 후 UI 업데이트
                                      let image = UIImage(data: imageData)
                                      self.profileImgIV.image = image
                                  }
                              }
                          }
                      }
                  }
               } else if response.value?.status == 401 || response.value?.statusCode == 401{
                  self.VCfunc.getAccessToken {
                     let newAccessToken = UserDefaults.standard.string(forKey: "accessToken")
                     if newAccessToken != token {
                        self.accessToken = UserDefaults.standard.string(forKey: "accessToken")!
                        self.userInfoRequest(token: newAccessToken)
                     } else {
                        self.VCfunc.showAlertAction1(vc: self, preferredStyle: .alert, title: "로그인 만료", message: "다시 로그인 해주시기 바랍니다.")
                        if let navigationController = self.navigationController {
                            navigationController.popToRootViewController(animated: true)
                        }
                     }
                  }
                  
               } else if response.value?.status == 404 {
                  self.VCfunc.showAlertAction1(vc: self, preferredStyle: .alert, title: "알림", message: "회원 정보를 확인할 수 없습니다.\n다시 로그인 해주세요.")
                  if let navigationController = self.navigationController {
                      navigationController.popToRootViewController(animated: true)
                  }
               } else if response.value?.status == 409 {
                   
               } else if response.value?.status == 422 {
                   self.VCfunc.showAlertAction1(vc: self, preferredStyle: .alert, title: "알림", message: "입력란을 다시 확인해 주세요.")
               }
                break
            case .failure(let error):
                print("Request Error\nCode:\(error._code), Message: \(error.errorDescription!)")
                self.VCfunc.showAlertAction1(vc: self, preferredStyle: .alert, title: "알림", message: "서버와의 통신에 오류가 발생하였습니다.")
            }
        }
    }
    
    // 이메일 인증코드 요청
    func emailRequest(email: String?) {
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
               if response.value?.status == 200 {
                  let responseJson = try? JSONEncoder().encode(response.value?.result)
                  let resultJson = try? JSONDecoder().decode(emailVerifyCode.self, from: responseJson!)
                  
                  let authCode = resultJson?.signupVerifyToken
                  print(authCode)
                  self.verifyCode = authCode!
                  
                  self.VCfunc.showAlertAction1(vc: self, preferredStyle: .alert, title: "알림", message: "이메일 발송 되었습니다.")
                  self.emailSent = true
               } else if response.value?.status == 401 || response.value?.statusCode == 401{
                  self.VCfunc.getAccessToken {
                     let newAccessToken = UserDefaults.standard.string(forKey: "accessToken")
                     if newAccessToken != self.accessToken {
                        self.accessToken = UserDefaults.standard.string(forKey: "accessToken")!
                        self.emailRequest(email: email)
                     } else {
                        self.VCfunc.showAlertAction1(vc: self, preferredStyle: .alert, title: "로그인 만료", message: "다시 로그인 해주시기 바랍니다.")
                        if let navigationController = self.navigationController {
                            navigationController.popToRootViewController(animated: true)
                        }
                     }
                  }
               } else if response.value?.status == 409{
                   
               }else if response.value?.status == 422{
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
    
    // 회원정보 수정
    func modifyRequest(email: String?, nickname: String?, token: String?, imageData: UIImage?) {
        let url = "https://api.reptimate.store/users"

        let header : HTTPHeaders = [
                    "Content-Type" : "multipart/form-data",
                    "Authorization" : "Bearer "+token! ]
            
        var params: [String : Any] = [:]
 
        if authBool { params.updateValue(email.flatMap({ $0.description }) ?? "", forKey: "email") }
        if nicknameChanged { params.updateValue(nickname.flatMap({ $0.description }) ?? "", forKey: "nickname") }
        AF.upload(multipartFormData: { multipartFormData in
                   for (key, value) in params {
                       multipartFormData.append("\(value)".data(using: .utf8)!, withName: key)
                   }
            if let image = imageData?.pngData() {
                       multipartFormData.append(image, withName: "file", fileName: "\(image).png", mimeType: "image/png")
                   }
               }, to: url, method: .patch, headers: header)
        .responseDecodable(of: messageResponse.self) { response in
                switch response.result {
                case .success:
                    if response.value?.status == 200 {
                        self.navigationController?.popViewController(animated: true)
                    } else if  response.value?.status == 401 || response.value?.statusCode == 401 {
                       self.VCfunc.getAccessToken {
                          let newAccessToken = UserDefaults.standard.string(forKey: "accessToken")
                          if newAccessToken != self.accessToken {
                             self.accessToken = UserDefaults.standard.string(forKey: "accessToken")!
                             self.modifyRequest(email: email, nickname: nickname, token: newAccessToken, imageData: imageData)
                          } else {
                             self.VCfunc.showAlertAction1(vc: self, preferredStyle: .alert, title: "로그인 만료", message: "다시 로그인 해주시기 바랍니다.")
                             if let navigationController = self.navigationController {
                                 navigationController.popToRootViewController(animated: true)
                             }
                          }
                       }
                    } else if  response.value?.status == 404 {
                       self.VCfunc.showAlertAction1(vc: self, preferredStyle: .alert, title: "알림", message: "회원 정보를 확인할 수 없습니다.\n다시 로그인 해주세요.")
                       if let navigationController = self.navigationController {
                           navigationController.popToRootViewController(animated: true)
                       }
                    } else if  response.value?.status == 409 {
                        
                    } else {
                        print(response.value?.message)
                        self.VCfunc.showAlertAction1(vc: self, preferredStyle: .alert, title: "알림", message: "서버와의 통신에 오류가 발생하였습니다.")
                    }
                    break
                case .failure(let error):
                    print("회원정보 수정 Request Error\nCode:\(error._code), Message: \(error.errorDescription!)")
                    self.VCfunc.showAlertAction1(vc: self, preferredStyle: .alert, title: "알림", message: "서버와의 통신에 오류가 발생하였습니다.")
                }
            LoadingService.hideLoading()
        }
    }
    // 비밀번호 수정
    func pwChangeRequest(currentPassword: Any?, newPassword: Any?, token: String?) {
        let url = "https://api.reptimate.store/users/password"
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer "+token! , forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 10
            
        // POST 로 보낼 정보
        let params = ["currentPassword": currentPassword,
                    "newPassword": newPassword
                    ] as Dictionary

        // httpBody 에 parameters 추가
        do {
            try request.httpBody = JSONSerialization.data(withJSONObject: params, options: [])
        } catch {
            print("http Body Error")
        }
        AF.request(request)
            .responseDecodable(of: messageResponse.self) { response in
                switch response.result {
                case .success:
                    
                   if response.value?.status == 200 {
                      self.VCfunc.showAlertAction1(vc: self, preferredStyle: .alert, title: "알림", message: "비밀번호가 변경 되었습니다.")
                      self.pwBtn.isHidden = false
                      self.pwChangeStackView.isHidden = !self.pwChangeStackView.isHidden
                   } else if  response.value?.status == 401 || response.value?.statusCode == 401 {
                      self.VCfunc.getAccessToken {
                         let newAccessToken = UserDefaults.standard.string(forKey: "accessToken")
                         if newAccessToken != self.accessToken {
                            self.accessToken = UserDefaults.standard.string(forKey: "accessToken")!
                            self.pwChangeRequest(currentPassword: currentPassword, newPassword: newPassword, token: newAccessToken)
                         } else {
                            self.VCfunc.showAlertAction1(vc: self, preferredStyle: .alert, title: "로그인 만료", message: "다시 로그인 해주시기 바랍니다.")
                            if let navigationController = self.navigationController {
                                navigationController.popToRootViewController(animated: true)
                            }
                         }
                      }
                   } else if  response.value?.status == 404 {
                      self.VCfunc.showAlertAction1(vc: self, preferredStyle: .alert, title: "알림", message: "회원 정보를 확인할 수 없습니다.\n다시 로그인 해주세요.")
                      if let navigationController = self.navigationController {
                          navigationController.popToRootViewController(animated: true)
                      }
                   } else if  response.value?.status == 409 {
                       
                   } else if  response.value?.status == 422 {
                      self.VCfunc.showAlertBox("입력란을 다시 확인해 주세요.")
                   } else {
                       print(response.value?.message)
                       self.VCfunc.showAlertAction1(vc: self, preferredStyle: .alert, title: "알림", message: "서버와의 통신에 오류가 발생하였습니다.")
                   }
                   
                    
//                    switch response.value?.status {
//                    case 200:
//                        self.VCfunc.showAlertAction1(vc: self, preferredStyle: .alert, title: "알림", message: "비밀번호가 변경 되었습니다.")
//                        self.pwBtn.isHidden = false
//                        self.pwChangeStackView.isHidden = !self.pwChangeStackView.isHidden
//                        break
//                    case 401 :
//                       //acessToken 재발급, 실패시 acessToken은 유지
//                       self.VCfunc.getAccessToken()
//                       let newAccessToken = UserDefaults.standard.string(forKey: "accessToken")
//                       if newAccessToken != self.accessToken {
//                          // 새로 발급받은 acessToken으로 api재시도
//                          self.accessToken = UserDefaults.standard.string(forKey: "accessToken")!
//                          self.pwChangeRequest(currentPassword: currentPassword, newPassword: newPassword, token: newAccessToken)
//                       } else {
//                          self.VCfunc.showAlertAction1(vc: self, preferredStyle: .alert, title: "알림", message: "다시 로그인 해주시기 바랍니다.")
//                          if let navigationController = self.navigationController {
//                              navigationController.popToRootViewController(animated: true)
//                          }
//                       }
//                        break
//                    case 404 :
//                       self.VCfunc.showAlertAction1(vc: self, preferredStyle: .alert, title: "알림", message: "회원 정보를 확인할 수 없습니다.\n다시 로그인 해주세요.")
//                       if let navigationController = self.navigationController {
//                           navigationController.popToRootViewController(animated: true)
//                       }
//                        break
//                    case 422 :
//                        self.VCfunc.showAlertBox("입력란을 다시 확인해 주세요.")
//                        break
//
//                    default:
//                        print("switch문 비밀번호 변경")
//                    }
//                    break
                case .failure(let error):
                    print("Request Error\nCode:\(error._code), Message: \(error.errorDescription!)")
                    self.VCfunc.showAlertAction1(vc: self, preferredStyle: .alert, title: "알림", message: "서버와의 통신에 오류가 발생하였습니다.")
                }
                LoadingService.hideLoading()
        }
    }
    
    
    @objc func movetoPhotoLibrary(sender: UITapGestureRecognizer){
        // [로직 처리 수행]
                DispatchQueue.main.async {
                    
                    // [앨범의 사진에 대한 접근 권한 확인 실시]
                    PHPhotoLibrary.requestAuthorization( { status in
                        switch status{
                        case .authorized:
                            print("")
                            print("====================================")
                            print("상태 :: 앨범 권한 허용")
                            print("====================================")
                            print("")
                            self.openPhoto()
                            break
                            
                        case .denied:
                            print("")
                            print("====================================")
                            print("상태 :: 앨범 권한 거부")
                            print("====================================")
                            print("")
                            break
                            
                        case .notDetermined:
                            print("")
                            print("====================================")
                            print("상태 :: 앨범 권한 선택하지 않음")
                            print("====================================")
                            print("")
                            break
                            
                        case .restricted:
                            print("")
                            print("====================================")
                            print("상태 :: 앨범 접근 불가능, 권한 변경이 불가능")
                            print("====================================")
                            print("")
                            break
                            
                        default:
                            print("")
                            print("====================================")
                            print("상태 :: default")
                            print("====================================")
                            print("")
                            break
                        }
                    })

                }
    }
    func openPhoto(){
        // [ImagePickerController 객체 생성 실시]
        let imagePicker = ImagePickerController()
        imagePicker.settings.theme.selectionStyle = .checked // 이미지 선택 시 표시
        imagePicker.settings.theme.backgroundColor = .white // 배경 색상
        imagePicker.albumButton.tintColor = .mainColor // 버튼 색상
        imagePicker.cancelButton.tintColor = .mainColor // 버튼 색상
        imagePicker.doneButton.tintColor = .mainColor // 버튼 색상
        imagePicker.settings.theme.selectionFillColor = UIColor.mainColor! // 선택 배경 색상 (Circle)
        imagePicker.settings.theme.selectionStrokeColor = .white // 선택 표시 색상 (Circle)
        imagePicker.settings.selection.max = 1 // 최대 선택 개수
        imagePicker.settings.fetch.assets.supportedMediaTypes = [.image] // 이미지 타입
        
        // [화면 전환 실시]
        self.presentImagePicker(imagePicker, select: { (asset) in
            print("[\(self.ACTIVITY_NAME) >> openPhoto() :: select]")
        }, deselect: { (asset) in
            print("[\(self.ACTIVITY_NAME) >> openPhoto() :: deselect]")
        }, cancel: { (assets) in
            print("[\(self.ACTIVITY_NAME) >> openPhoto() :: cancel]")
        }, finish: { (assets) in
            print("[\(self.ACTIVITY_NAME) >> openPhoto() :: finish]")
            print("선택한 이미지 정보 :: \(assets.description)")
            guard let firstAsset = assets.first else {
                    return
            }
            let imageManager = PHImageManager.default()
            let option = PHImageRequestOptions()
            option.isSynchronous = true
            var thumbnail = UIImage()
            
            let desiredSize = CGSize(width: 720, height: 720)
            let scale = UIScreen.main.scale // 현재 화면 스케일
            let targetSize = CGSize(width: desiredSize.width * scale, height: desiredSize.height * scale)
            
            imageManager.requestImage(for: firstAsset,
                    targetSize: targetSize,
                    contentMode: .aspectFit, options: option) { (result, info) in
                    thumbnail = result!
                    }
           let data = thumbnail.jpegData(compressionQuality: 1.0)
            let newImage = UIImage(data: data!)
                    
            // [이미지 뷰에 표시 실시]
            self.profileImgIV.image = newImage! as UIImage
            self.selectedImage = newImage! as UIImage 
        })
        /**
         구버전 --> 직접찍은 사진은 업로드가 안되어 변경
         DispatchQueue.main.async {
             self.imagePickerController.delegate = self // 앨범 컨트롤러 딜리게이트 지정 실시
             self.imagePickerController.sourceType = .photoLibrary // 앨범 지정 실시
             self.imagePickerController.allowsEditing = true // MARK: 편집을 허용
             self.present(self.imagePickerController, animated: false, completion: nil)
         }
         */
    }

    
    //  입력창 에러문구 출력
    @objc func textFieldEdited(textField: UITextField) {
        
        if textField == changePwTextField{
            if isValidPassword(pwStr: textField.text) { pwderrorheight.isActive = true
            } else { pwderrorheight.isActive = false
            }
        }
        
        UIView.animate(withDuration: 0.1) { // 효과 주기
            self.view.layoutIfNeeded()
        }
    }
    
    func isValidPassword(pwStr: String?) -> Bool{
        let pwdregex = "^(?=.*[A-Za-z])(?=.*[0-9])(?=.*[!@#$%^&*()_+=-]).{8,50}"
        let pwdtest = NSPredicate(format:"SELF MATCHES %@", pwdregex)
        return pwdtest.evaluate(with: pwStr)
    }
    
    
    
    
    
    
}

//
//// MARK: [앨범 선택한 이미지 정보를 확인 하기 위한 딜리게이트 선언]
//extension ModifyInfo_MyPageViewController: UIImagePickerControllerDelegate,  UINavigationControllerDelegate{
//
//    // MARK: [사진, 비디오 선택을 했을 때 호출되는 메소드]
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        if let img = info[UIImagePickerController.InfoKey.originalImage]{
//
//            // [앨범에서 선택한 사진 정보 확인]
//            print("")
//            print("====================================")
//            print("[사진 정보 :: ", info)
//            print("====================================")
//            print("")
//
//
//            // [이미지 뷰에 앨범에서 선택한 사진 표시 실시]
//            self.profileImgIV.image = img as? UIImage
//            self.selectedImage = img as? UIImage
//        }
//        // [이미지 파커 닫기 수행]
//        dismiss(animated: true, completion: nil)
//    }
//
//
//
//    // MARK: [사진, 비디오 선택을 취소했을 때 호출되는 메소드]
//    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//        print("")
//        print("====================================")
//        print("[A_Intro >> imagePickerControllerDidCancel() :: 사진, 비디오 선택 취소 수행 실시]")
//        print("====================================")
//        print("")
//
//        // [이미지 파커 닫기 수행]
//        self.dismiss(animated: true, completion: nil)
//    }
//}
