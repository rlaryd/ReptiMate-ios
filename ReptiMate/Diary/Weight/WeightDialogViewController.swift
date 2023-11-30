//
//  WeightDialogViewController.swift


import UIKit
import Alamofire


protocol DataUpdateDelegate: AnyObject {
    func didUpdateData(_ viewController: WeightDialogViewController, updatedData: String)
}
protocol WeightDialogViewControllerDelegate: AnyObject {
    func didFinishEditingCell(updatedData: petWeightDetailItem, indexPath: IndexPath)
}

class WeightDialogViewController: UIViewController, UITextFieldDelegate {
    let VCfunc: VCfunc = .init()
    
    var accessToken = ""
    var petInfo: petListItem?
    var isEdit: Bool?
    var isEdits: String = ""
    var indexPath: IndexPath?
    
    var petWeightDetailItem: petWeightDetailItem?
    let datePicker = UIDatePicker()
    
    var changedDate: String = ""
    var changedWeight: String?
    
    weak var delegate: DataUpdateDelegate?
    weak var delegate2: WeightDialogViewControllerDelegate?
    
    @IBOutlet weak var backgroundBtn: UIButton!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var saveBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTap()
        
        
        print("WeightDialogViewController : viewDidLoad")
        accessToken = UserDefaults.standard.string(forKey: "accessToken")!
        if accessToken == nil {
            navigationController?.popViewController(animated: true)
        }
        
        weightTextField.delegate = self
                
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("WeightDialogViewController : viewWillAppear")
        if let isEdit = self.isEdit {
            var date = petWeightDetailItem?.date!.split(separator: "T")
            dateTextField.text = String(date![0])
            
            if let weight = petWeightDetailItem?.weight {
                weightTextField.text = String(weight)
            }
        }
        dateTextField.addTarget(self, action: #selector(textFieldDidBeginEditing), for: .editingDidBegin)
    }
    @IBAction func saveBtnTapped(_ sender: Any) {
        if weightTextField.hasText && dateTextField.hasText {
            if self.isEdit != nil {
                editWeightRequest(weightIdx: (petWeightDetailItem?.idx)!, weight: Float(weightTextField.text!)!, date: dateTextField.text, token: accessToken)
            } else {
                AddWeightRequest(petIdx: (petInfo?.idx)!, weight: Float(weightTextField.text!)!, date: dateTextField.text, token: accessToken)
            }
        } else {
            self.VCfunc.showAlertAction1(vc: self, preferredStyle: .alert, title: "알림", message: "체중과 날짜는 필수 입력란 입니다.")
        }
        //delegate2?.didFinishEditingCell()
        
    }
    
    // 배경을 탭 하였을 때
    @IBAction func backgroundTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        //self.navigationController?.popViewController(animated: true)
    }
    
    // 추가나 수정이 이루어 졌을 때
    func updateDataAndDismiss() {
        self.delegate?.didUpdateData(self, updatedData: "123")
        
        dismiss(animated: true, completion: nil)
        //self.navigationController?.popViewController(animated: true)
    }
    // =======
    // api 요청
    // =======
    // 체중 등록
    func AddWeightRequest(petIdx: Int, weight: Float, date: String?, token: String?) {
        LoadingService.showLoading()
        print("=======입력된 체중은====================weight : \(weight)")
        let url = "https://api.reptimate.store/diaries/pet/\(petIdx)/weight"
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer "+token! , forHTTPHeaderField: "Authorization")
        
        let params = ["weight": weight as Float,
                      "date": date] as [String : Any] as Dictionary
        print("=======파라미터는====================params : \(params)")
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
                    print("AddWeightRequest : \(response)")
                    if response.value?.status == 201 {
                        self.updateDataAndDismiss()
                    } else if response.value?.status == 401 || response.value?.statusCode == 401{
                        //acessToken 재발급, 실패시 acessToken은 유지
                        self.VCfunc.getAccessToken() {
                            let newAccessToken = UserDefaults.standard.string(forKey: "accessToken")
                            if newAccessToken != self.accessToken {
                               self.accessToken = UserDefaults.standard.string(forKey: "accessToken")!
                               // 새로 발급받은 acessToken(newAccessToken)으로 api재시도
                               self.AddWeightRequest(petIdx: petIdx, weight: weight, date: date, token: newAccessToken)
                            } else {
                               self.VCfunc.showAlertAction1(vc: self, preferredStyle: .alert, title: "로그인 만료", message: "다시 로그인 해주시기 바랍니다.")
                               if let navigationController = self.navigationController {
                                   self.dismiss(animated: true, completion: nil)
                                   navigationController.popToRootViewController(animated: true)
                               }
                            }
                        }
                        
                    } else if  response.value?.status == 404 {
                        switch response.value?.errorCode {
                        case "CANNOT_FIND_PET":
                            self.VCfunc.showAlertAction1(vc: self, preferredStyle: .alert, title: "알림", message: "등록한 반려동물 정보를 찾을 수 없습니다.")
                            self.dismiss(animated: true, completion: nil)
                        case "CANNOT_FIND_WEIGHT":
                            self.VCfunc.showAlertAction1(vc: self, preferredStyle: .alert, title: "알림", message: "등록한 체중 정보를 찾을 수 없습니다..")
                            self.dismiss(animated: true, completion: nil)
                        case .none: break
                        case .some(_): break
                        }
                    } else if  response.value?.status == 409 {
                        print("=========AddWeightRequest  에러=========")
                        print(response.value?.status as Any)
                        print(response.value?.message as Any)
                        print("=======================================")
                    } else if response.value?.status == 422 {
                        self.VCfunc.showAlertAction1(vc: self, preferredStyle: .alert, title: "알림", message: "입력란을 다시 확인해 주세요.")
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
    func editWeightRequest(weightIdx: Int, weight: Float, date: String?, token: String?) {
        LoadingService.showLoading()
        let url = "https://api.reptimate.store/diaries/weight/\(weightIdx)"
        print("=======입력된 체중은====================weight : \(weight)")
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer "+token! , forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 10
        
        
        var params = ["weight": weight as Float] as [String : Any] as Dictionary
        if (self.changedDate != "") { params.updateValue(date.flatMap({ $0.description }) ?? "", forKey: "date") }
        print("=======파라미터는====================params : \(params)")
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
                        
                        var newData = ReptiMate.petWeightDetailItem(idx: self.petWeightDetailItem?.idx, weight: Float(self.weightTextField.text!), date: self.dateTextField.text)
                        self.delegate2?.didFinishEditingCell(updatedData: newData, indexPath: self.indexPath!)
                        self.dismiss(animated: true, completion: nil)
                    } else if response.value?.status == 401 || response.value?.statusCode == 401{
                        //acessToken 재발급, 실패시 acessToken은 유지
                        self.VCfunc.getAccessToken() {
                            let newAccessToken = UserDefaults.standard.string(forKey: "accessToken")
                            if newAccessToken != self.accessToken {
                               self.accessToken = UserDefaults.standard.string(forKey: "accessToken")!
                               // 새로 발급받은 acessToken(newAccessToken)으로 api재시도
                               self.editWeightRequest(weightIdx: weightIdx, weight: weight, date: date, token: newAccessToken)
                            } else {
                               self.VCfunc.showAlertAction1(vc: self, preferredStyle: .alert, title: "로그인 만료", message: "다시 로그인 해주시기 바랍니다.")
                                self.dismiss(animated: true, completion: nil)
                               if let navigationController = self.navigationController {
                                   navigationController.popToRootViewController(animated: true)
                               }
                            }
                        }
                        
                    } else if  response.value?.status == 404 {
                        switch response.value?.errorCode {
                        case "CANNOT_FIND_PET":
                            self.VCfunc.showAlertAction1(vc: self, preferredStyle: .alert, title: "알림", message: "등록한 반려동물 정보를 찾을 수 없습니다.")
                            self.dismiss(animated: true, completion: nil)
                        case "CANNOT_FIND_WEIGHT":
                            self.VCfunc.showAlertAction1(vc: self, preferredStyle: .alert, title: "알림", message: "등록한 체중 정보를 찾을 수 없습니다..")
                            self.dismiss(animated: true, completion: nil)
                        case .none: break
                        case .some(_): break
                        }
                    } else if  response.value?.status == 409 {
                        
                    } else if response.value?.status == 422 {
                        self.VCfunc.showAlertAction1(vc: self, preferredStyle: .alert, title: "알림", message: "입력란을 다시 확인해 주세요.")
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
    
    @objc func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == dateTextField {
            createDatePickerView()
        }
    }
    @objc func createDatePickerView(){
        //toolbar 만들기, done 버튼이 들어갈 곳
        let toolbar = UIToolbar()
        toolbar.sizeToFit() //view 스크린에 딱 맞게 사이즈 조정
        
        //버튼 만들기
        let doneButton = UIBarButtonItem(title: "선택",style: .plain, target : self, action: #selector(dateDonePressed))
        doneButton.tintColor = .mainColor
        //action 자리에는 이후에 실행될 함수가 들어간다?
        
        datePicker.tintColor = .mainColor
        datePicker.datePickerMode = .date
        datePicker.locale = Locale(identifier: "ko_KR")
        if #available(iOS 14.0, *) {
                datePicker.preferredDatePickerStyle = .inline
            } else {
                datePicker.preferredDatePickerStyle = .automatic
        }
        //버튼 툴바에 할당
        toolbar.setItems([UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), doneButton], animated: true)
        
        //toolbar를 키보드 대신 할당?
        dateTextField.inputAccessoryView = toolbar
        //assign datepicker to the textfield, 텍스트 필드에 datepicker 할당
        dateTextField.inputView = datePicker
    }
    
    @objc func dateDonePressed(){
        
        let formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateFormat = "yyyy-MM-dd"
        dateTextField.text = formatter.string(from: datePicker.date)
        changedDate = formatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
                let newText = (currentText as NSString).replacingCharacters(in: range, with: string)

                let decimalSeparator = Locale.current.decimalSeparator ?? "."
                let decimalComponents = newText.components(separatedBy: decimalSeparator)
                let decimalCount = decimalComponents.count

                if decimalCount <= 2 {
                    if decimalComponents.count == 2 && decimalComponents[1].count > 1 {
                        return false // 소수점 이하 자리가 2자리 이상인 경우 입력 방지
                    }
                    let allowedCharacterSet = CharacterSet(charactersIn: "0123456789\(decimalSeparator)")
                    let filteredString = string.components(separatedBy: allowedCharacterSet.inverted).joined()

                    return string == filteredString
                } else {
                    return false // 소수점 이상 입력 방지
                }
    }

}

