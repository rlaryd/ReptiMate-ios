

import UIKit
import Alamofire


class Home_MyPageViewController: UIViewController {
    
    let VCfunc: VCfunc = .init()
    //let LoadingService: LoadingService = .init()
    
    var userInfo: userResponseResult?
    var userName = ""
    var userEmail = ""
    var accessToken = ""
    
    var idx = ""
    var profilePath = ""
    var isPremium = ""
    var agreeWithMarketing = ""
    var createdAt = ""
    var loginMethod = ""
    
    @IBOutlet weak var profile_Img: UIImageView!
    @IBOutlet weak var nickname_Label: UILabel!
    @IBOutlet weak var email_Label: UILabel!
    
    @IBOutlet weak var socialTypeImg: UIImageView!
    @IBOutlet weak var LCageControl: UILabel!
    @IBOutlet weak var LScheduling: UILabel!
    @IBOutlet weak var LModifyInfo: UILabel!
    @IBOutlet weak var LAppOption: UILabel!
    
    @IBOutlet weak var iotStackView: UIStackView!
    
    var iotStackViewHeight: NSLayoutConstraint!
    var socialTypeImgHeight: NSLayoutConstraint!
    var socialTypeImgWidth: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()


    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        accessToken = UserDefaults.standard.string(forKey: "accessToken")!
        //var asx = UserDefaults.standard.string(forKey: "refreshToken")!
        print("accessToken  :  \(accessToken)")
        //print("refToken  :  \(asx)")
        if accessToken == nil {
            navigationController?.popViewController(animated: true)
        }
        
        profile_Img.layer.cornerRadius = profile_Img.frame.height/2
        profile_Img.layer.borderWidth = 1
        profile_Img.layer.borderColor = UIColor.clear.cgColor
        profile_Img.clipsToBounds = true
        
        let moveToModify = UITapGestureRecognizer(target: self, action: #selector(clickPoint))
        LModifyInfo.isUserInteractionEnabled = true
        LModifyInfo.addGestureRecognizer(moveToModify)
        
        let moveToSettings = UITapGestureRecognizer(target: self, action: #selector(moveToSettings))
        LAppOption.isUserInteractionEnabled = true
        LAppOption.addGestureRecognizer(moveToSettings)
        
        let moveToSchedule = UITapGestureRecognizer(target: self, action: #selector(moveToSchedule))
        LScheduling.isUserInteractionEnabled = true
        LScheduling.addGestureRecognizer(moveToSchedule)
        
        let moveToMyboard = UITapGestureRecognizer(target: self, action: #selector(moveToMyBoard))
        LCageControl.isUserInteractionEnabled = true
        LCageControl.addGestureRecognizer(moveToMyboard)
        
        userInfoRequest(token: accessToken)
    }
    
    // =======
    // api 요청
    // =======
    // 회원정보 불러오기
    func userInfoRequest(token: String?) {
        LoadingService.showLoading()

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
                print(res)
                if response.value?.status == 200 {
                    let responseJson = try? JSONEncoder().encode(res.result)
                    let resultJson = try? JSONDecoder().decode(userResponseResult.self, from: responseJson!)
                    self.userInfo = resultJson
                    self.userName = resultJson?.nickname ?? ""
                    self.userEmail = resultJson?.email ?? ""
                    self.nickname_Label.text = self.userName
                    self.email_Label.text = self.userEmail
                    let loginMethod = resultJson?.loginMethod ?? ""
                    print("================================")
                    print("userInfoRequest  :  \(resultJson)")
                    print("================================")
                    
                    UserDefaults.standard.set(resultJson?.nickname ?? "", forKey: "nickname")
                    UserDefaults.standard.set(resultJson?.profilePath ?? "", forKey: "profilePath")
                    UserDefaults.standard.set(resultJson?.idx ?? 0, forKey: "idx")
                    
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
                                        self.profile_Img.image = image
//                                        self.setSocialImg(socialType: loginMethod)
                                    }
                                }
                            }
                        }
                    }
                    
                } else if response.value?.status == 401 || response.value?.statusCode == 401{
                   //acessToken 재발급, 실패시 acessToken은 유지
                    self.VCfunc.getAccessToken() {
                        let newAccessToken = UserDefaults.standard.string(forKey: "accessToken")
                        if newAccessToken != self.accessToken {
                            self.accessToken = UserDefaults.standard.string(forKey: "accessToken")!
                           // 새로 발급받은 acessToken으로 api재시도
                            self.userInfoRequest(token: newAccessToken)
                        } else {
                           self.VCfunc.showAlertAction1(vc: self, preferredStyle: .alert, title: "로그인 만료", message: "다시 로그인 해주시기 바랍니다.")
                           if let navigationController = self.navigationController {
                               navigationController.popToRootViewController(animated: true)
                           }
                        }
                    }
                   
                } else if response.value?.status == 404 {
                    self.VCfunc.showAlertAction1(vc: self, preferredStyle: .alert, title: "알림", message: "회원정보가 조회되지 않습니다. \n다시 로그인 해주세요.")
                    UserDefaults.standard.removeObject(forKey: "accessToken")
                    UserDefaults.standard.removeObject(forKey: "refreshToken")
                    UserDefaults.standard.synchronize()
                    if let navigationController = self.navigationController {
                        navigationController.popToRootViewController(animated: true)
                    }
                } else if response.value?.status == 422 {
                    self.VCfunc.showAlertAction1(vc: self, preferredStyle: .alert, title: "알림", message: "입력란을 다시 확인해 주세요.")
                } else {
                    self.VCfunc.showAlertAction1(vc: self, preferredStyle: .alert, title: "알림", message: "\(String(describing: response.value?.status)) : 서버와의 통신에 오류가 발생하였습니다.")
                }
                LoadingService.hideLoading()
                break
            case .failure(let error):
                print("Request Error\nCode:\(error._code), Message: \(error.errorDescription!)")
                self.VCfunc.showToast(message: "서버와의 통신에 오류가 발생하였습니다.", wid: 180)
            }
        }

    }
    
//    func setSocialImg(socialType: String?) {
//        switch socialType {
//        case "KAKAO" :
//            DispatchQueue.main.async {
//                self.socialTypeImg.image = UIImage(named: "ic_kaka")
//            }
//        case "GOOGLE" :
//            DispatchQueue.main.async {
//                self.socialTypeImg.image = UIImage(named: "ic_google")
//            }
//        case "APPLE" :
//            DispatchQueue.main.async {
//                self.socialTypeImg.image = UIImage(named: "ic_apple")
//            }
//        default :
//            socialTypeImgHeight = socialTypeImg.heightAnchor.constraint(equalToConstant: 0)
//            socialTypeImgWidth = socialTypeImg.widthAnchor.constraint(equalToConstant: 0)
//            socialTypeImgWidth.isActive = true
//            socialTypeImgHeight.isActive = true
//            break
//        }
//    }
    
    @objc func clickPoint(sender: UITapGestureRecognizer){
        guard let Home_MyPageViewController = self.storyboard?.instantiateViewController(withIdentifier: "ModifyInfo_MyPageViewController") as? ModifyInfo_MyPageViewController  else { return }
        // 회원가입 완료시 토스트 메시지 위한 delegate
        //Home_MyPageViewController.delegate = self
        self.navigationController?.pushViewController(Home_MyPageViewController, animated: true)    
    }
    
    @objc func moveToSettings(sender: UITapGestureRecognizer){
        guard let Setting_MyPageViewController = self.storyboard?.instantiateViewController(withIdentifier: "Setting_MyPageViewController") as? Setting_MyPageViewController  else { return }
        //
        Setting_MyPageViewController.userInfo = self.userInfo
        
        self.navigationController?.pushViewController(Setting_MyPageViewController, animated: true)
    }
    @objc func moveToSchedule(sender: UITapGestureRecognizer){
        guard let scheduleTabmanViewController = self.storyboard?.instantiateViewController(withIdentifier: "scheduleTabmanViewController") as? scheduleTabmanViewController  else { return }
        // 회원가입 완료시 토스트 메시지 위한 delegate
        self.navigationController?.pushViewController(scheduleTabmanViewController, animated: true)
    }
    @objc func moveToMyBoard(sender: UITapGestureRecognizer){
        guard let MyBoard_MyPageViewController = self.storyboard?.instantiateViewController(withIdentifier: "MyBoard_MyPageViewController") as? MyBoard_MyPageViewController  else { return }
        // 회원가입 완료시 토스트 메시지 위한 delegate
        self.navigationController?.pushViewController(MyBoard_MyPageViewController, animated: true)
    }
    
    
}
