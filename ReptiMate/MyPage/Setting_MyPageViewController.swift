

import UIKit
import Alamofire


class Setting_MyPageViewController: UIViewController {
    
    let VCfunc: VCfunc = .init()
    
    var userInfo: userResponseResult?
    var userInfoA: userResponseResult?
    
    var userName = ""
    var userEmail = ""
    var accessToken = ""
    
    var idx = ""
    var profilePath = ""
    var isPremium = ""
    var agreeWithMarketing = ""
    var createdAt = ""
    var loginMethod = ""
    
    var isEdited = false
    
    @IBOutlet weak var allNotiSwitch: UISwitch!
    @IBOutlet weak var boardNotiSwitch: UISwitch!
    @IBOutlet weak var adNotiSwitch: UISwitch!
    
    @IBOutlet weak var logOutLabel: UILabel!
    @IBOutlet weak var deleteUserLabel: UILabel!
    
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var saveBtn: UIButton!
    
    @IBOutlet weak var deleteUserModal: UIView!
    
    @IBOutlet weak var deleteUserModalConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var deleteUserConfirmBtn: UIButton!
    @IBOutlet weak var deleteUserCancelBtn: UIButton!
    
    @IBOutlet weak var deleteUserTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.swipeRecognizer()
        self.hideKeyboardWhenTap()
        
        accessToken = UserDefaults.standard.string(forKey: "accessToken")!
        
        let logoutClicked = UITapGestureRecognizer(target: self, action: #selector(logoutClicked))
        logOutLabel.isUserInteractionEnabled = true
        logOutLabel.addGestureRecognizer(logoutClicked)
        
        let userDeleteClicked = UITapGestureRecognizer(target: self, action: #selector(userDeleteClicked))
        deleteUserLabel.isUserInteractionEnabled = true
        deleteUserLabel.addGestureRecognizer(userDeleteClicked)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 변경사항 유무 확인 및 적용
        if isEdited {
            
        }
    }
    
    // =======
    // api 요청
    // =======
    // 회원정보 수정사항 반영
    func userInfoRequest(token: String?) {
        
    }
    
    func logOut(token: String?) {
        let url = "https://api.reptimate.store/auth/logout"
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
                UserDefaults.standard.removeObject(forKey: "accessToken")
                UserDefaults.standard.removeObject(forKey: "refreshToken")
                UserDefaults.standard.synchronize()
                self.navigationController?.popToRootViewController(animated: true)
                break
            case .failure(let error):
                print("Request Error\nCode:\(error._code), Message: \(error.errorDescription!)")
                self.VCfunc.showToast(message: "서버 오류가 발생하였습니다.", wid: 180)
            }
        }
    }
    func deleteAccount(token: String?, password: String?) {
        let url = "https://api.reptimate.store/auth/users"
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer "+token! , forHTTPHeaderField: "Authorization")

        // POST 로 보낼 정보
        let params = ["password": password] as Dictionary

        // httpBody 에 parameters 추가
        do {
            try request.httpBody = JSONSerialization.data(withJSONObject: params, options: [])
        } catch {
            print("http Body Error")
        }
        
        // POST 로 보낼 정보
        AF.request(url,
                method: .get,
                parameters: nil,
                encoding: URLEncoding.default,
                   headers: ["Content-Type":"application/json", "Accept":"application/json", "Authorization":"Bearer "+token!])
            .responseDecodable(of: userInfoResponse.self) { response in
            switch response.result {
            case .success (let res):
                
                if (res.status == 200) {
                    UserDefaults.standard.removeObject(forKey: "accessToken")
                    UserDefaults.standard.removeObject(forKey: "refreshToken")
                    UserDefaults.standard.synchronize()
                    self.navigationController?.popToRootViewController(animated: true)
                    break
                } else {
                    self.VCfunc.showToast(message: "회원 탈퇴에 실패 하였습니다.", wid: 180)
                }
                
            case .failure(let error):
                print("Request Error\nCode:\(error._code), Message: \(error.errorDescription!)")
                self.VCfunc.showToast(message: "서버 오류가 발생하였습니다.", wid: 180)
            }
        }
    }
    
    @IBAction func saveBtnPressed(_ sender: Any) {
        
    }
    
    @IBAction func userDeleteBtnPressed(_ sender: Any) {
        deleteAccount(token: self.accessToken, password: deleteUserTextField.text)
    }
    @IBAction func userDeleteCancelBtnPressed(_ sender: Any) {
        self.deleteUserModalConstraint.constant = 1000
        self.view.layoutIfNeeded()
    }
    
    
    @IBAction func switchEvent(_ sender: UISwitch) {
        switch sender {
        case self.allNotiSwitch :
            if self.boardNotiSwitch.isOn && self.adNotiSwitch.isOn {
                self.boardNotiSwitch.setOn(false, animated: true)
                self.adNotiSwitch.setOn(false, animated: true)
                self.allNotiSwitch.setOn(false, animated: true)
            } else {
                self.boardNotiSwitch.setOn(true, animated: true)
                self.adNotiSwitch.setOn(true, animated: true)
                self.allNotiSwitch.setOn(true, animated: true)
            }
            break
        case self.boardNotiSwitch :
            if self.boardNotiSwitch.isOn {
                self.boardNotiSwitch.setOn(false, animated: true)
            } else {
                self.boardNotiSwitch.setOn(true, animated: true)
                if self.boardNotiSwitch.isOn && self.adNotiSwitch.isOn {
                    self.allNotiSwitch.setOn(true, animated: true)
                }
            }
            break
        case self.adNotiSwitch :
            if self.adNotiSwitch.isOn {
                self.adNotiSwitch.setOn(false, animated: true)
            } else {
                self.adNotiSwitch.setOn(true, animated: true)
                if self.boardNotiSwitch.isOn && self.adNotiSwitch.isOn {
                    self.allNotiSwitch.setOn(true, animated: true)
                }
            }
            break
        default: break
        }
        
        
    }
    
    
    
    
    @objc func logoutClicked(sender: UITapGestureRecognizer){
        logOut(token: accessToken)
    }
    
    @objc func userDeleteClicked(sender: UITapGestureRecognizer){
//        UserDefaults.standard.removeObject(forKey: "accessToken")
//        self.navigationController?.popToRootViewController(animated: true)
        
        self.deleteUserModalConstraint.constant = 0
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

