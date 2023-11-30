//
//  makePlanViewController.swift
//  ReptiMate
//
//  Created by 김기용 on 2023/06/14.
//

import UIKit
import Alamofire

class makePlanViewController: UIViewController, cycleSelectViewControllerDelegate {
    
    let planListTableViewCell: planListTableViewCell = .init()
    let VCfunc: VCfunc = .init()
    
    var accessToken = ""
    var isEdit: Bool = false
    var isEdits: String = ""
    var indexPath: IndexPath?
    
    var repeatString: String = ""
    
    var scheduleInfo: ScheduleStructs?
    

    @IBOutlet weak var headerLabel: UILabel!
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var repeatLabel: UILabel!
    @IBOutlet weak var memoTextView: UITextView!
    @IBOutlet weak var saveBtn: UIButton!
    
    @IBOutlet weak var backBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTap()
        self.swipeRecognizer()
        
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

        let moveToSchedule = UITapGestureRecognizer(target: self, action: #selector(moveToSchedule))
        repeatLabel.isUserInteractionEnabled = true
        repeatLabel.addGestureRecognizer(moveToSchedule)
        
        memoTextView.translatesAutoresizingMaskIntoConstraints = false
        memoTextView.delegate = self
        memoTextView.text = "내용을 입력하세요."
        memoTextView.textColor = UIColor.lightGray
        memoTextView.textContainerInset = UIEdgeInsets(top: 12.0, left: 10.0, bottom: 12.0, right: 10.0)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isEdit {
            headerLabel.text = "일정 수정"
            saveBtn.titleLabel?.text = "수정하기"
            
            titleTextField.text = scheduleInfo?.title
            repeatLabel.text = planListTableViewCell.getRepeatDayString((scheduleInfo?.repeatDay)!)
            memoTextView.text = scheduleInfo?.memo
            memoTextView.textColor = UIColor.black
            repeatString = (scheduleInfo?.repeatDay)!
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            dateFormatter.locale = NSLocale.current
            dateFormatter.timeZone = TimeZone(abbreviation: "GMT+9:00")
            let initialTime = scheduleInfo?.alarmTime // 초기값으로 설정할 시간 (24시간 형식)
            if let date = dateFormatter.date(from: initialTime!) {
                datePicker.date = date
            }
            
        } else {
            repeatString = "0,0,0,0,0,0,0"
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
                editPlanRequest(title: titleTextField.text, alarmTime: dateString, repeatDay: repeatString, memo: memoTextView.text, type: "REPETITION", token: accessToken, idx: scheduleInfo?.idx!)
            } else {
                AddPlanRequest(title: titleTextField.text, alarmTime: dateString, repeatDay: repeatString, memo: memoTextView.text, type: "REPETITION", token: accessToken)
            }
        }
        
        
    }
    // =======
    // api 요청
    // =======
    // 체중 등록
    func AddPlanRequest(title: String?, alarmTime: String?, repeatDay: String?, memo: String?, type: String?, token: String?) {
        LoadingService.showLoading()
        let url = "https://api.reptimate.store/schedules"
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer "+token! , forHTTPHeaderField: "Authorization")
        
        var params: [String : Any] = [:]

        if (title != "") { params.updateValue(title.flatMap({ $0.description }) ?? "", forKey: "title") }
        if (alarmTime != "") { params.updateValue(alarmTime.flatMap({ $0.description }) ?? "", forKey: "alarmTime") }
        if (repeatDay != "") { params.updateValue(repeatDay.flatMap({ $0.description }) ?? "", forKey: "repeatDay") }
        if (memo != "") { params.updateValue(memo.flatMap({ $0.description }) ?? "", forKey: "memo") }
        if (type != "") { params.updateValue(type.flatMap({ $0.description }) ?? "", forKey: "type") }
        //if (date != "") { params.updateValue(date.flatMap({ $0.description }) ?? "", forKey: "date") }
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
                        //self.updateDataAndDismiss()
                        self.navigationController?.popViewController(animated: true)
                    } else if response.value?.status == 401 || response.value?.statusCode == 401{
                        //acessToken 재발급, 실패시 acessToken은 유지
                        self.VCfunc.getAccessToken() {
                            let newAccessToken = UserDefaults.standard.string(forKey: "accessToken")
                            if newAccessToken != self.accessToken {
                               self.accessToken = UserDefaults.standard.string(forKey: "accessToken")!
                               // 새로 발급받은 acessToken(newAccessToken)으로 api재시도
                               self.AddPlanRequest(title: title, alarmTime: alarmTime, repeatDay: repeatDay, memo: memo, type: type, token: newAccessToken)
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
    // 체중 수정
    func editPlanRequest(title: String?, alarmTime: String?, repeatDay: String?, memo: String?, type: String?, token: String?, idx: Int?) {
        LoadingService.showLoading()
        var url = ""
        if let value = idx {
            url = "https://api.reptimate.store/schedules/\(value)"
        } else {
            url = "https://api.reptimate.store/schedules/\(idx)"
        }

        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer "+token! , forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 10
        
        var params: [String : Any] = [:]

        if (title != "") { params.updateValue(title.flatMap({ $0.description }) ?? "", forKey: "title") }
        if (alarmTime != "") { params.updateValue(alarmTime.flatMap({ $0.description }) ?? "", forKey: "alarmTime") }
        if (repeatDay != "") { params.updateValue(repeatDay.flatMap({ $0.description }) ?? "", forKey: "repeatDay") }
        if (memo != "") { params.updateValue(memo.flatMap({ $0.description }) ?? "", forKey: "memo") }
        if (type != "") { params.updateValue(type.flatMap({ $0.description }) ?? "", forKey: "type") }
        //if (date != "") { params.updateValue(date.flatMap({ $0.description }) ?? "", forKey: "date") }
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
                    if response.value?.status == 200 {
                        self.navigationController?.popViewController(animated: true)
                    } else if response.value?.status == 401 || response.value?.statusCode == 401{
                        //acessToken 재발급, 실패시 acessToken은 유지
                        self.VCfunc.getAccessToken() {
                            let newAccessToken = UserDefaults.standard.string(forKey: "accessToken")
                            if newAccessToken != self.accessToken {
                               self.accessToken = UserDefaults.standard.string(forKey: "accessToken")!
                               // 새로 발급받은 acessToken(newAccessToken)으로 api재시도
                               self.editPlanRequest(title: title, alarmTime: alarmTime, repeatDay: repeatDay, memo: memo, type: type, token: newAccessToken, idx: idx)
                            } else {
                               self.VCfunc.showAlertAction1(vc: self, preferredStyle: .alert, title: "로그인 만료", message: "다시 로그인 해주시기 바랍니다.")
                               if let navigationController = self.navigationController {
                                   navigationController.popToRootViewController(animated: true)
                               }
                            }
                        }
                        
                    } else if  response.value?.status == 404 {
                        UserDefaults.standard.removeObject(forKey: "accessToken")
                        UserDefaults.standard.removeObject(forKey: "refreshToken")
                        UserDefaults.standard.synchronize()
                        self.VCfunc.showAlertAction1(vc: self, preferredStyle: .alert, title: "알림", message: "회원 정보를 확인할 수 없습니다.\n다시 로그인 해주세요.")
                        if let navigationController = self.navigationController {
                            navigationController.popToRootViewController(animated: true)
                        }
                    } else if  response.value?.status == 409 {
                        
                    } else if response.value?.status == 422 {
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
    
    
    @objc func moveToSchedule(sender: UITapGestureRecognizer){
        guard let cycleSelectViewController = self.storyboard?.instantiateViewController(withIdentifier: "cycleSelectViewController") as? cycleSelectViewController  else { return }
        // cycleSelectViewController의 반복일 설정을 위한 delegate
        cycleSelectViewController.delegate = self
        if self.repeatString != "0,0,0,0,0,0,0" {
            cycleSelectViewController.isEdit = true
            
            cycleSelectViewController.radioArray = getRepeatDayArray(self.repeatString)
            print("============intArr : \(getRepeatDayArray(self.repeatString))==================")
        }
        
        
        self.navigationController?.pushViewController(cycleSelectViewController, animated: true)
    }
    func dataSend(data: String) {
        // 날짜 반복 String("0,0,0,0,0,0,0" 의 형식)을 받아와서 반영
        if data.lengthOfBytes(using: String.Encoding.utf8) > 0 {
            DispatchQueue.main.async {
                self.repeatString = data
                self.repeatLabel.text = self.getRepeatDayString(data)
            }
        }
    }
    func getRepeatDayString(_ repeatDay: String) -> String {
        var repeats = ""
        var repeatsArray : [String] = []
        
        var sun = repeatDay.substring(from: 0, to: 0)
        var mon = repeatDay.substring(from: 2, to: 2)
        var tue = repeatDay.substring(from: 4, to: 4)
        var wed = repeatDay.substring(from: 6, to: 6)
        var thu = repeatDay.substring(from: 8, to: 8)
        var fri = repeatDay.substring(from: 10, to: 10)
        var sat = repeatDay.substring(from: 12, to: 12)
        
        if sun == "1" { sun = "일"
            repeatsArray.append(sun) }
        if mon == "1" { mon = "월"
            repeatsArray.append(mon) }
        if tue == "1" { tue = "화"
            repeatsArray.append(tue) }
        if wed == "1" { wed = "수"
            repeatsArray.append(wed) }
        if thu == "1" { thu = "목"
            repeatsArray.append(thu) }
        if fri == "1" { fri = "금"
            repeatsArray.append(fri) }
        if sat == "1" { sat = "토"
            repeatsArray.append(sat) }
        
        if repeatsArray.isEmpty {
            repeats = "반복 안함"
        } else if repeatsArray.count == 7 {
            repeats = "매일"
        }  else if repeatsArray.count == 2 && repeatsArray.contains("일") && repeatsArray.contains("토") {
            repeats = "주말"
        }  else if repeatsArray.count == 5 && !repeatsArray.contains("일") && !repeatsArray.contains("토") {
            repeats = "주중"
        } else {
            for i in stride(from: 0, to: repeatsArray.count, by: 1) {
                repeats = repeats + repeatsArray[i]
                if i < repeatsArray.count - 1 && repeatsArray.count != 0 {
                    repeats = repeats + ","
                }
            }
        }
        return repeats
    }
    func getRepeatDayArray(_ repeatDay: String) -> [Int] {
        var repeatsArray : [Int] = []
        
        let sun = repeatDay.substring(from: 0, to: 0)
        let mon = repeatDay.substring(from: 2, to: 2)
        let tue = repeatDay.substring(from: 4, to: 4)
        let wed = repeatDay.substring(from: 6, to: 6)
        let thu = repeatDay.substring(from: 8, to: 8)
        let fri = repeatDay.substring(from: 10, to: 10)
        let sat = repeatDay.substring(from: 12, to: 12)
        
        if sun == "1" { repeatsArray.append(1) } else { repeatsArray.append(0) }
        if mon == "1" { repeatsArray.append(1) } else { repeatsArray.append(0) }
        if tue == "1" { repeatsArray.append(1) } else { repeatsArray.append(0) }
        if wed == "1" { repeatsArray.append(1) } else { repeatsArray.append(0) }
        if thu == "1" { repeatsArray.append(1) } else { repeatsArray.append(0) }
        if fri == "1" { repeatsArray.append(1) } else { repeatsArray.append(0) }
        if sat == "1" { repeatsArray.append(1) } else { repeatsArray.append(0) }
        
        return repeatsArray
    }
}
extension makePlanViewController: UITextViewDelegate {
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
