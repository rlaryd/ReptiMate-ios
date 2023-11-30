//
//  makeCalendarViewController.swift
//  ReptiMate
//
//  Created by 김기용 on 2023/06/19.
//

import UIKit
import Alamofire

class makeCalendarViewController: UIViewController {

    //let planListTableViewCell: planListTableViewCell = .init()
    let VCfunc: VCfunc = .init()
    
    var accessToken = ""
    var isEdit: Bool = false
    var isEdits: String = ""
    var indexPath: IndexPath?
    
    var selectedDate: String = ""
    
    var scheduleInfo: CalendarStructs?
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var memoTextView: UITextView!
    @IBOutlet weak var saveBtn: UIButton!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var backBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTap()
        self.VCfunc.swipeRecognizer()
        
        accessToken = UserDefaults.standard.string(forKey: "accessToken")!
        if accessToken == nil {
            navigationController?.popViewController(animated: true)
        }
        
        datePicker.datePickerMode = .time
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        dateFormatter.locale = NSLocale.current
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT+9:00")
        let dateString2 = dateFormatter.string(from: datePicker.date)

        
        memoTextView.translatesAutoresizingMaskIntoConstraints = false
        memoTextView.delegate = self
        memoTextView.text = "내용을 입력하세요."
        memoTextView.textColor = UIColor.lightGray
        memoTextView.textContainerInset = UIEdgeInsets(top: 12.0, left: 10.0, bottom: 12.0, right: 10.0)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isEdit {
            
            titleTextField.text = scheduleInfo?.title
            memoTextView.text = scheduleInfo?.memo
            memoTextView.textColor = UIColor.black
            dateLabel.text = scheduleInfo?.date
            selectedDate = (scheduleInfo?.date)!
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            dateFormatter.locale = NSLocale.current
            dateFormatter.timeZone = TimeZone(abbreviation: "GMT+9:00")
            let initialTime = scheduleInfo?.alarmTime // 초기값으로 설정할 시간 (24시간 형식)
            if let date = dateFormatter.date(from: initialTime!) {
                datePicker.date = date
            }
            
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            dateFormatter.locale = NSLocale.current
            dateFormatter.timeZone = TimeZone(abbreviation: "GMT+9:00")
            let initialTime = Date()
            if let date = dateFormatter.string(from: initialTime) as? String {
                dateLabel.text = date
            }
            
            
            print("selectedDate : \(selectedDate)")
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            self.memoTextView.resignFirstResponder()
    }
    @IBAction func backBtnPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveBtnPressed(_ sender: Any) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        dateFormatter.locale = NSLocale.current
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT+9:00")
        let dateString = dateFormatter.string(from: datePicker.date)
        
        if titleTextField.hasText {
            if isEdit {
                print("===========editCalendarRequest==========")
                editCalendarRequest(title: titleTextField.text, alarmTime: dateString, memo: memoTextView.text, type: "CALENDAR", date: selectedDate, token: accessToken, idx: scheduleInfo?.idx!)
            } else {
                AddCalendarRequest(title: titleTextField.text, alarmTime: dateString, memo: memoTextView.text, type: "CALENDAR", date: selectedDate, token: accessToken)
            }
        } else {
            self.VCfunc.showAlertAction1(vc: self, preferredStyle: .alert, title: "알림", message: "스케줄 제목은 필수 기입란 입니다.")
        }
    }
    // =======
    // api 요청
    // =======
    // 달력 스케줄 추가
    func AddCalendarRequest(title: String?, alarmTime: String?, memo: String?, type: String?, date: String?, token: String?) {
        LoadingService.showLoading()
        let url = "https://api.reptimate.store/schedules"
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer "+token! , forHTTPHeaderField: "Authorization")
        
        var params: [String : Any] = [:]

        if (title != "") { params.updateValue(title.flatMap({ $0.description }) ?? "", forKey: "title") }
        if (alarmTime != "") { params.updateValue(alarmTime.flatMap({ $0.description }) ?? "", forKey: "alarmTime") }
        if (memo != "") { params.updateValue(memo.flatMap({ $0.description }) ?? "", forKey: "memo") }
        if (type != "") { params.updateValue(type.flatMap({ $0.description }) ?? "", forKey: "type") }
        if (date != "") { params.updateValue(date.flatMap({ $0.description }) ?? "", forKey: "date") }
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
                    print("AddPlanRequest : \(response)")
                    if response.value?.status == 201 {
                        self.navigationController?.popViewController(animated: true)
                    } else if response.value?.status == 401 || response.value?.statusCode == 401 {
                        //acessToken 재발급, 실패시 acessToken은 유지
                        self.VCfunc.getAccessToken() {
                            let newAccessToken = UserDefaults.standard.string(forKey: "accessToken")
                            if newAccessToken != self.accessToken {
                               self.accessToken = UserDefaults.standard.string(forKey: "accessToken")!
                               // 새로 발급받은 acessToken(newAccessToken)으로 api재시도
                                self.AddCalendarRequest(title: title, alarmTime: alarmTime, memo: memo, type: type, date: date, token: newAccessToken)
                            } else {
                               self.VCfunc.showAlertAction1(vc: self, preferredStyle: .alert, title: "로그인 만료", message: "다시 로그인 해주시기 바랍니다.")
                               if let navigationController = self.navigationController {
                                   navigationController.popToRootViewController(animated: true)
                               }
                            }
                        }
                        
                    } else if  response.value?.status == 404 {
                        print("=========AddWeightRequest  에러=========")
                        print(response.value?.status as Any)
                        print(response.value?.message as Any)
                        print("=======================================")
                        self.VCfunc.showAlertAction1(vc: self, preferredStyle: .alert, title: "알림", message: "회원 정보를 확인할 수 없습니다.\n다시 로그인 해주세요.")
                        UserDefaults.standard.removeObject(forKey: "accessToken")
                        UserDefaults.standard.removeObject(forKey: "refreshToken")
                        UserDefaults.standard.synchronize()
                        if let navigationController = self.navigationController {
                            navigationController.popToRootViewController(animated: true)
                        }
                    } else if  response.value?.status == 409 {
                        print("=========AddWeightRequest  에러=========")
                        print(response.value?.status as Any)
                        print(response.value?.message as Any)
                        print("=======================================")
                    } else if response.value?.status == 422 {
                        print("=========AddWeightRequest  에러=========")
                        print(response.value?.status as Any)
                        print(response.value?.message as Any)
                        print("=======================================")
                        self.VCfunc.showAlertAction1(vc: self, preferredStyle: .alert, title: "알림", message: "입력란을 확인해 주세요.")
                    } else {
                        print("=========AddWeightRequest  에러=========")
                        print(response.value?.status as Any)
                        print(response.value?.message as Any)
                        print("=======================================")
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
    // 달력 스케줄 수정
    func editCalendarRequest(title: String?, alarmTime: String?, memo: String?, type: String?, date: String?, token: String?, idx: Int?) {
        LoadingService.showLoading()
        var url = ""
        if let value = idx {
            url = "https://api.reptimate.store/schedules/\(value)"
        } else {
            url = "https://api.reptimate.store/schedules/\(idx)"
        }
        print(url)
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer "+token! , forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 10
        
        var params: [String : Any] = [:]

        if (title != "") { params.updateValue(title.flatMap({ $0.description }) ?? "", forKey: "title") }
        if (alarmTime != "") { params.updateValue(alarmTime.flatMap({ $0.description }) ?? "", forKey: "alarmTime") }
        if (memo != "") { params.updateValue(memo.flatMap({ $0.description }) ?? "", forKey: "memo") }
        if (type != "") { params.updateValue(type.flatMap({ $0.description }) ?? "", forKey: "type") }
        if (date != "") { params.updateValue(date.flatMap({ $0.description }) ?? "", forKey: "date") }
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
                    print("=========================")
                    print("=========================")
                    print("url :  \(url)")
                    print("params :  \(params)")
                    print("response :  \(response)")
                    print("=========================")
                    print("=========================")
                    if response.value?.status == 200 {
                        self.navigationController?.popViewController(animated: true)
                    } else if response.value?.status == 401 || response.value?.statusCode == 401{
                        //acessToken 재발급, 실패시 acessToken은 유지
                        self.VCfunc.getAccessToken() {
                            let newAccessToken = UserDefaults.standard.string(forKey: "accessToken")
                            if newAccessToken != self.accessToken {
                               self.accessToken = UserDefaults.standard.string(forKey: "accessToken")!
                               // 새로 발급받은 acessToken(newAccessToken)으로 api재시도
                                self.editCalendarRequest(title: title, alarmTime: alarmTime, memo: memo, type: type, date: date, token: newAccessToken, idx: idx)
                            } else {
                               self.VCfunc.showAlertAction1(vc: self, preferredStyle: .alert, title: "로그인 만료", message: "다시 로그인 해주시기 바랍니다.")
                               if let navigationController = self.navigationController {
                                   navigationController.popToRootViewController(animated: true)
                               }
                            }
                        }
                        
                    } else if  response.value?.status == 404 {
                        self.VCfunc.showAlertAction1(vc: self, preferredStyle: .alert, title: "알림", message: "회원 정보를 확인할 수 없습니다.\n다시 로그인 해주세요.")
                        UserDefaults.standard.removeObject(forKey: "accessToken")
                        UserDefaults.standard.removeObject(forKey: "refreshToken")
                        UserDefaults.standard.synchronize()
                        if let navigationController = self.navigationController {
                            navigationController.popToRootViewController(animated: true)
                        }
                    } else if  response.value?.status == 409 {
                        
                    } else if response.value?.status == 422 {
                        print(response.value?.status)
                        self.VCfunc.showAlertAction1(vc: self, preferredStyle: .alert, title: "알림", message: "입력란을 확인해 주세요.")
                    } else {
                        print(response.value?.message)
                        print(response.value?.status)
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
    
    
}
extension makeCalendarViewController: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
            if memoTextView.text.isEmpty {
                memoTextView.text =  "내용을 입력하세요."
                memoTextView.textColor = UIColor.lightGray
            }
        }
        func textViewDidBeginEditing(_ textView: UITextView) {
            if memoTextView.textColor == UIColor.lightGray {
                memoTextView.text = nil
                memoTextView.textColor = UIColor.black
            }
        }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let inputString = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let oldString = textView.text, let newRange = Range(range, in: oldString) else { return true }
        let newString = oldString.replacingCharacters(in: newRange, with: inputString).trimmingCharacters(in: .whitespacesAndNewlines)
        let characterCount = newString.count
        guard characterCount <= 200 else { return false }

        return true
    }
}
