//  Diary_EditAnimalViewController.swift
//  ReptiMate

import UIKit
import Alamofire
import PhotosUI
import BSImagePicker

class Diary_EditAnimalViewController: UIViewController, UITextFieldDelegate {
    let VCfunc: VCfunc = .init()
    
    var idx: Int?
    
    var accessToken = ""
    
    var petInfo: petListItem?
    
    var gender = "NONE"
    let ACTIVITY_NAME = "Diary_EditAnimalViewController"
    let datePicker = UIDatePicker()
    var dateTime: String?
    
    var selectedImage: UIImage? = nil
    
    let imagePickerController = UIImagePickerController()

    
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var AnimalProfileImageView: UIImageView!
    
    @IBOutlet weak var AnimalGenderMaleBtn: UIButton!
    @IBOutlet weak var AnimalGenderFemaleBtn: UIButton!
    @IBOutlet weak var AnimalGenderNoneBtn: UIButton!
    @IBOutlet weak var AnimalEditBtn: UIButton!
    
    @IBOutlet weak var AnimalNameTextField: UITextField!
    @IBOutlet weak var AnimalTypeTextField: UITextField!
    @IBOutlet weak var AnimalBirthDateTextField: UITextField!
    
    @IBOutlet weak var AnimalAdoptDateTextField: UITextField!
    

    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.swipeRecognizer()
        self.hideKeyboardWhenTap()
        
        if let Token = UserDefaults.standard.string(forKey: "accessToken") {
            accessToken = Token
        } else {
            navigationController?.popViewController(animated: true)
        }
        
        AnimalGenderMaleBtn.setBackgroundColor(.genderMaleSelected!, for: .selected)
        AnimalGenderFemaleBtn.setBackgroundColor(.genderFemaleSelected!, for: .selected)
        AnimalGenderNoneBtn.setBackgroundColor(.genderNoneSelected!, for: .selected)
        
        AnimalBirthDateTextField.addTarget(self, action: #selector(textFieldDidBeginEditing), for: .editingDidBegin)
        AnimalAdoptDateTextField.addTarget(self, action: #selector(textFieldDidBeginEditing), for: .editingDidBegin)
        
        AnimalProfileImageView.layer.cornerRadius = AnimalProfileImageView.frame.height/2
        AnimalProfileImageView.layer.borderWidth = 2
        AnimalProfileImageView.layer.borderColor = UIColor.systemBackground.cgColor
        AnimalProfileImageView.clipsToBounds = true

        let buyPoint = UITapGestureRecognizer(target: self, action: #selector(movetoPhotoLibrary))
        AnimalProfileImageView.isUserInteractionEnabled = true
        AnimalProfileImageView.addGestureRecognizer(buyPoint)
        
        setData(petInfo!)
        
        
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
//    @IBAction func AnimalBirthDatePick(_ sender: Any) {
//        //createBirthPickerView()
//    }
//    @IBAction func AnimalAdoptDatePick(_ sender: Any) {
//        //createAdoptPickerView()
//    }
    
    @IBAction func EditAnimal(_ sender: Any) {
        if AnimalNameTextField == nil && AnimalTypeTextField == nil {
            VCfunc.showAlertAction1(vc: self, preferredStyle: .alert, title: "알림", message: "이름과 품종은 필수 입력값 입니다.")
        } else {
            EditAnimalRequest(idx: (petInfo?.idx)!, name: AnimalNameTextField.text, type: AnimalTypeTextField.text, gender: gender, birthDate: AnimalBirthDateTextField.text, adoptionDate: AnimalAdoptDateTextField.text, token: accessToken, imageData: selectedImage)
        }
    }
    
    // =======
    // api 요청
    // =======

    // 회원정보 수정
    func EditAnimalRequest(idx: Int, name: String?, type: String?, gender: String?, birthDate: String?, adoptionDate: String?, token: String?, imageData: UIImage?) {
        LoadingService.showLoading()
        let url = "https://api.reptimate.store/diaries/pet/\(idx)"

        let header : HTTPHeaders = [
                    "Content-Type" : "multipart/form-data",
                    "Authorization" : "Bearer "+token! ]
            
        var params: [String : Any] = [:]

        if (name != "") { params.updateValue(name.flatMap({ $0.description }) ?? "", forKey: "name") }
        if (type != "") { params.updateValue(type.flatMap({ $0.description }) ?? "", forKey: "type") }
        if (gender != "") { params.updateValue(gender.flatMap({ $0.description }) ?? "", forKey: "gender") }
        if (birthDate != "") { params.updateValue(birthDate.flatMap({ $0.description }) ?? "", forKey: "birthDate") }
        if (adoptionDate != "") { params.updateValue(adoptionDate.flatMap({ $0.description }) ?? "", forKey: "adoptionDate") }
        
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
                        print("펫 등록 완료")
                        self.navigationController?.popViewController(animated: true)
                    } else if response.value?.status == 401 || response.value?.statusCode == 401{
                        //acessToken 재발급, 실패시 acessToken은 유지
                        self.VCfunc.getAccessToken() {
                            let newAccessToken = UserDefaults.standard.string(forKey: "accessToken")
                            if newAccessToken != self.accessToken {
                               self.accessToken = UserDefaults.standard.string(forKey: "accessToken")!
                               // 새로 발급받은 acessToken(newAccessToken)으로 api재시도
                               self.EditAnimalRequest(idx: idx, name: name, type: type, gender: gender, birthDate: birthDate, adoptionDate: adoptionDate, token: newAccessToken, imageData: imageData)
                            } else {
                               self.VCfunc.showAlertAction1(vc: self, preferredStyle: .alert, title: "로그인 만료", message: "다시 로그인 해주시기 바랍니다.")
                               if let navigationController = self.navigationController {
                                   navigationController.popToRootViewController(animated: true)
                               }
                            }
                        }
                        
                    } else if  response.value?.status == 404 {
                        self.VCfunc.showAlertAction1(vc: self, preferredStyle: .alert, title: "알림", message: "반려동물 정보를 확인할 수 없습니다.")
                        self.navigationController?.popViewController(animated: true)
                    } else if  response.value?.status == 409 {
                        
                    } else if  response.value?.status == 422 {
                        self.VCfunc.showAlertAction1(vc: self, preferredStyle: .alert, title: "알림", message: "입력란을 다시 확인해 주세요.")
                    }  else {
                        print(response.value?.message)
                        self.VCfunc.showAlertAction1(vc: self, preferredStyle: .alert, title: "알림", message: "서버와의 통신에 오류가 발생하였습니다.")
                    }

                    break
                case .failure(let error):
                    print("정보 수정 Request Error\nCode:\(error._code), Message: \(error.errorDescription!)")
                    self.VCfunc.showAlertAction1(vc: self, preferredStyle: .alert, title: "알림", message: "서버와의 통신에 오류가 발생하였습니다.")
                }
            LoadingService.hideLoading()
        }
        
    }
    
    // =========
    // 뷰 동적 처리
    // =========
    func setData(_ petListItem: petListItem) {
        
        idx = petListItem.idx
        
        if ((petListItem.imagePath) != nil) {
            // 이미지 경로 URL 생성
            let imageURL = URL(string: (petListItem.imagePath)!)

            // URL을 통해 이미지 다운로드
            if let url = imageURL {
                DispatchQueue.global(qos: .userInitiated).async {
                    if let imageData = try? Data(contentsOf: url) {
                        DispatchQueue.main.async {
                            // 이미지 다운로드가 완료된 후 UI 업데이트
                            let image = UIImage(data: imageData)
                            self.AnimalProfileImageView.image = image
                            self.AnimalProfileImageView.layer.cornerRadius = self.AnimalProfileImageView.frame.height/2
                            self.AnimalProfileImageView.layer.borderWidth = 2
                            self.AnimalProfileImageView.layer.borderColor = UIColor.systemBackground.cgColor
                            self.AnimalProfileImageView.clipsToBounds = true
                            
                            self.AnimalProfileImageView.translatesAutoresizingMaskIntoConstraints = false
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.AnimalProfileImageView.image = UIImage(named: "png+3+(1)")
                    self.AnimalProfileImageView.layer.cornerRadius = self.AnimalProfileImageView.frame.height/2
                    self.AnimalProfileImageView.layer.borderWidth = 2
                    self.AnimalProfileImageView.layer.borderColor = UIColor.systemBackground.cgColor
                    self.AnimalProfileImageView.clipsToBounds = true
                }
                
            }
        }
        AnimalNameTextField.text = petListItem.name
        AnimalTypeTextField.text = petListItem.type
        
        var birth = petListItem.birthDate?.split(separator: "T")
        var adopt = petListItem.adoptionDate?.split(separator: "T")
        
        
        AnimalBirthDateTextField.text = String(birth?[0] ?? "")
        AnimalAdoptDateTextField.text = String(adopt?[0] ?? "")
        
        
        
        if petListItem.gender == "MALE" {
            AnimalGenderMaleBtn.isSelected = true
            gender = "MALE"
        } else if petListItem.gender == "FEMALE" {
            AnimalGenderFemaleBtn.isSelected = true
            gender = "FEMALE"
        } else {
            AnimalGenderNoneBtn.isSelected = true
            gender = "NONE"
        }
        
    }
    // 성별 선택 이벤트
    @IBAction func GenderClick(_ sender: UIButton) {
        if sender == AnimalGenderMaleBtn {
            if AnimalGenderMaleBtn.isSelected {
                AnimalGenderMaleBtn.isSelected = false
                gender = "NONE"
            } else {
                AnimalGenderMaleBtn.isSelected = true
                AnimalGenderFemaleBtn.isSelected = false
                AnimalGenderNoneBtn.isSelected = false
                gender = "MALE"
            }
        } else if sender == AnimalGenderFemaleBtn {
            if AnimalGenderFemaleBtn.isSelected {
                AnimalGenderFemaleBtn.isSelected = false
                gender = "NONE"
            } else {
                AnimalGenderMaleBtn.isSelected = false
                AnimalGenderFemaleBtn.isSelected = true
                AnimalGenderNoneBtn.isSelected = false
                gender = "FEMALE"
            }
        } else if sender == AnimalGenderNoneBtn {
            if AnimalGenderNoneBtn.isSelected {
                AnimalGenderNoneBtn.isSelected = false
                gender = "NONE"
            } else {
                AnimalGenderMaleBtn.isSelected = false
                AnimalGenderFemaleBtn.isSelected = false
                AnimalGenderNoneBtn.isSelected = true
                gender = "NONE"
            }
        }
    }
    @objc func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == AnimalBirthDateTextField {
            createBirthPickerView()
        } else if textField == AnimalAdoptDateTextField {
            createAdoptPickerView()
        }
    }
    @objc func BirthdonePressed(){
        
        let formatter = DateFormatter()
        
        formatter.timeStyle = .none
        formatter.dateFormat = "yyyy-MM-dd"
                
        AnimalBirthDateTextField.text = formatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }
    @objc func AdoptdonePressed(){
        
        let formatter = DateFormatter()
        
        formatter.timeStyle = .none
        formatter.dateFormat = "yyyy-MM-dd"
                
        AnimalAdoptDateTextField.text = formatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }
    
    @objc func createBirthPickerView(){
        //toolbar 만들기, done 버튼이 들어갈 곳
        let toolbar = UIToolbar()
        toolbar.sizeToFit() //view 스크린에 딱 맞게 사이즈 조정
        
        //버튼 만들기
        let doneButton = UIBarButtonItem(title: "선택",style: .plain, target : self, action: #selector(BirthdonePressed))
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
        AnimalBirthDateTextField.inputAccessoryView = toolbar
        //assign datepicker to the textfield, 텍스트 필드에 datepicker 할당
        AnimalBirthDateTextField.inputView = datePicker
    }
    @objc func createAdoptPickerView(){
        //toolbar 만들기, done 버튼이 들어갈 곳
        let toolbar = UIToolbar()
        toolbar.sizeToFit() //view 스크린에 딱 맞게 사이즈 조정
        
        //버튼 만들기
        let doneButton = UIBarButtonItem(title: "선택",style: .plain, target : self, action: #selector(AdoptdonePressed))
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
        AnimalAdoptDateTextField.inputAccessoryView = toolbar
        //assign datepicker to the textfield, 텍스트 필드에 datepicker 할당
        AnimalAdoptDateTextField.inputView = datePicker
    }
    
    
    
    @objc func movetoPhotoLibrary(sender: UITapGestureRecognizer){
        // [로직 처리 수행]
                DispatchQueue.main.async {
                    // [앨범의 사진에 대한 접근 권한 확인 실시]
                    PHPhotoLibrary.requestAuthorization( { status in
                        switch status{
                        case .authorized:
                            self.openPhoto()
                            break
                            
                        case .denied:
                            break
                            
                        case .notDetermined:
                            break
                            
                        case .restricted:
                            break
                            
                        default:
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
            let data = thumbnail.jpegData(compressionQuality: 1)
            let newImage = UIImage(data: data!)
                    
            // [이미지 뷰에 표시 실시]
            self.AnimalProfileImageView.image = newImage! as UIImage
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

}
//// MARK: [앨범 선택한 이미지 정보를 확인 하기 위한 딜리게이트 선언]
//extension Diary_EditAnimalViewController: UIImagePickerControllerDelegate,  UINavigationControllerDelegate{
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
//            self.AnimalProfileImageView.image = img as? UIImage
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
