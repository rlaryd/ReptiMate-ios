//
//  PetMemo_WriteViewController.swift

import UIKit
import Alamofire
import BSImagePicker
import PhotosUI

protocol editProtocol {
  func dataSend(data: String)
}

class PetMemo_WriteViewController: UIViewController {
    let VCfunc: VCfunc = .init()
    var petInfo:petListItem?
    
    var delegate : editProtocol?
    
    var accessToken = ""
    var isEdit: Bool?
    var petMemoDetail: MemoDetailResponse?
    var imgList: [petMemoDetailImgItem] = []
    
    let textViewPlaceHolder = "내용을 입력하세요"
    let ACTIVITY_NAME = "PetMemo_WriteViewController"
    
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var getImageBtn: UIButton!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contextTextView: UITextView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var selectedImgs: [UIImage] = []
    
    @IBOutlet weak var imgCountLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.swipeRecognizer()
        self.hideKeyboardWhenTap()
        
        accessToken = UserDefaults.standard.string(forKey: "accessToken")!
        if accessToken == nil {
            navigationController?.popViewController(animated: true)
        }
        
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView.dragDelegate = self
        collectionView.dropDelegate = self
        collectionView.dragInteractionEnabled = true

        contextTextView.translatesAutoresizingMaskIntoConstraints = false
        contextTextView.delegate = self
        contextTextView.text = "내용을 입력하세요."
        contextTextView.textColor = UIColor.lightGray
        contextTextView.textContainerInset = UIEdgeInsets(top: 12.0, left: 10.0, bottom: 12.0, right: 10.0)
        
        if isEdit ?? false {
            self.titleTextField.text = petMemoDetail?.title
            self.contextTextView.text = petMemoDetail?.content
            contextTextView.textColor = UIColor.black
            
            if imgList.count > 0 {
                imgCountLabel.text = String(imgList.count)
                self.collectionView.reloadData()
                for i in stride(from: 0, to: imgList.count, by: 1) {
                    
                    let imageURL = URL(string: (imgList[i].imagePath!))
                    print(imageURL)
                    
                    if let url = imageURL{
                        DispatchQueue.main.async {
                                    
                            URLSession.shared.dataTask(with: url) { (data, result, error) in
                                guard error == nil else {
                                    DispatchQueue.main.async { [weak self] in
                                        let image = UIImage()
                                        self?.selectedImgs.append(image)
                                    }
                                    return
                                }
                                DispatchQueue.main.async { [weak self] in
                                    if let data = data, let image = UIImage(data: data) {
                                        self?.selectedImgs.append(image)
                                        self?.collectionView.reloadData()
                                    }
                                }
                            }.resume()
                        }
                    }
                } // for
            } else {
                imgCountLabel.text = "0"
            }
        } else {
            imgCountLabel.text = "0"
        } // isEdit?
        
        
        
        

        
    }// didload
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            self.contextTextView.resignFirstResponder()
    }
    
    
    @IBAction func backBtnPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func memoSave(_ sender: Any) {
        if titleTextField.hasText {
            if isEdit ?? false {
                MemoEditRequest(idx: (petMemoDetail?.idx)!, title: titleTextField.text, content: contextTextView.text, token: accessToken, imageDatas: selectedImgs)
            } else {
                MemoRequest(idx: (petInfo?.idx)!, title: titleTextField.text, content: contextTextView.text, token: accessToken, imageDatas: selectedImgs)
            }
        } else {
            self.VCfunc.showAlertAction1(vc: self, preferredStyle: .alert, title: "알림", message: "제목은 필수 입력란 입니다.")
        }
        
    }
    
    @IBAction func pressedGetImgBtn(_ sender: Any) {
        testMain()
    }
    
    func MemoRequest(idx: Int, title: String?, content: String?, token: String?, imageDatas: [UIImage]) {
        LoadingService.showLoading()
        let url = "https://api.reptimate.store/diaries/\(idx)"
        let header : HTTPHeaders = [
                    "Content-Type" : "multipart/form-data",
                    "Authorization" : "Bearer "+token! ]
            
        var params: [String : Any] = [:]
        if (title != "") { params.updateValue(title.flatMap({ $0.description }) ?? "", forKey: "title") }
        if (content != "") { params.updateValue(content.flatMap({ $0.description }) ?? "", forKey: "content") }
        
        AF.upload(multipartFormData: { multipartFormData in
                   for (key, value) in params {
                       multipartFormData.append("\(value)".data(using: .utf8)!, withName: key)
                   }
            if !imageDatas.isEmpty {
                for img in imageDatas {
                    if let image = img.pngData() {
                       multipartFormData.append(image, withName: "files", fileName: "\(image).png", mimeType: "image/png")
                   }
                }
            }
        }, to: url, method: .post, headers: header)
        .responseDecodable(of: messageResponse.self) { response in
                switch response.result {
                case .success:
                    if response.value?.status == 201 {
                        print("펫 등록 완료")
                        self.navigationController?.popViewController(animated: true)
                    } else if response.value?.status == 401 || response.value?.statusCode == 401{
                        //acessToken 재발급, 실패시 acessToken은 유지
                        self.VCfunc.getAccessToken() {
                            let newAccessToken = UserDefaults.standard.string(forKey: "accessToken")
                            if newAccessToken != self.accessToken {
                               self.accessToken = UserDefaults.standard.string(forKey: "accessToken")!
                               // 새로 발급받은 acessToken(newAccessToken)으로 api재시도
                               self.MemoRequest(idx: idx, title: title, content: content, token: newAccessToken, imageDatas: imageDatas)
                            } else {
                               self.VCfunc.showAlertAction1(vc: self, preferredStyle: .alert, title: "로그인 만료", message: "다시 로그인 해주시기 바랍니다.")
                               if let navigationController = self.navigationController {
                                   navigationController.popToRootViewController(animated: true)
                               }
                            }
                        }
                        
                    } else if  response.value?.status == 404 {
                        switch response.value?.errorCode {
                        case "CANNOT_FIND_PET":
                            self.VCfunc.showAlertAction1(vc: self, preferredStyle: .alert, title: "알림", message: "등록한 반려동물 정보를 찾을 수 없습니다.")
                            self.navigationController?.popViewController(animated: true)
                        case "CANNOT_FIND_DIARY":
                            self.VCfunc.showAlertAction1(vc: self, preferredStyle: .alert, title: "알림", message: "등록한 메모를 찾을 수 없습니다.")
                            self.navigationController?.popViewController(animated: true)
                        case .none: break
                        case .some(_): break
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
    func MemoEditRequest(idx: Int, title: String?, content: String?, token: String?, imageDatas: [UIImage]) {
        LoadingService.showLoading()
        let url = "https://api.reptimate.store/diaries/\(idx)"
        let header : HTTPHeaders = [
                    "Content-Type" : "multipart/form-data",
                    "Authorization" : "Bearer "+token! ]
            
        var params: [String : Any] = [:]
        if (title != "") { params.updateValue(title.flatMap({ $0.description }) ?? "", forKey: "title") }
        if (content != "") { params.updateValue(content.flatMap({ $0.description }) ?? "", forKey: "content") }
        
        AF.upload(multipartFormData: { multipartFormData in
                   for (key, value) in params {
                       multipartFormData.append("\(value)".data(using: .utf8)!, withName: key)
                   }
            if !imageDatas.isEmpty {
                for img in imageDatas {
                    if let image = img.pngData() {
                       multipartFormData.append(image, withName: "files", fileName: "\(image).png", mimeType: "image/png")
                   }
                }
            }
        }, to: url, method: .patch, headers: header)
        .responseDecodable(of: messageResponse.self) { response in
                switch response.result {
                case .success:
                    if response.value?.status == 200 {
                        print("수정 완료")
                        self.delegate?.dataSend(data: "수정")
                        self.navigationController?.popViewController(animated: true)
                    } else if response.value?.status == 401 || response.value?.statusCode == 401{
                        //acessToken 재발급, 실패시 acessToken은 유지
                        self.VCfunc.getAccessToken() {
                            let newAccessToken = UserDefaults.standard.string(forKey: "accessToken")
                            if newAccessToken != self.accessToken {
                               self.accessToken = UserDefaults.standard.string(forKey: "accessToken")!
                               // 새로 발급받은 acessToken(newAccessToken)으로 api재시도
                               self.MemoEditRequest(idx: idx, title: title, content: content, token: newAccessToken, imageDatas: imageDatas)
                            } else {
                               self.VCfunc.showAlertAction1(vc: self, preferredStyle: .alert, title: "로그인 만료", message: "다시 로그인 해주시기 바랍니다.")
                               if let navigationController = self.navigationController {
                                   navigationController.popToRootViewController(animated: true)
                               }
                            }
                        }
                        
                    } else if  response.value?.status == 404 {
                        switch response.value?.errorCode {
                        case "CANNOT_FIND_PET":
                            self.VCfunc.showAlertAction1(vc: self, preferredStyle: .alert, title: "알림", message: "등록한 반려동물 정보를 찾을 수 없습니다.")
                            self.navigationController?.popViewController(animated: true)
                        case "CANNOT_FIND_DIARY":
                            self.VCfunc.showAlertAction1(vc: self, preferredStyle: .alert, title: "알림", message: "등록한 메모를 찾을 수 없습니다.")
                            self.navigationController?.popViewController(animated: true)
                        case .none: break
                        case .some(_): break
                        }
                    } else if  response.value?.status == 409 {
                        
                    } else if  response.value?.status == 422 {
                        self.VCfunc.showAlertAction1(vc: self, preferredStyle: .alert, title: "알림", message: "입력란을 확인해 주시기 바랍니다.")
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
    
    func testMain() {
            print("====================================")
            print("[\(self.ACTIVITY_NAME) >> testMain() :: 테스트 함수 시작 실시]")
            print("====================================")
            // [로직 처리 수행]
        DispatchQueue.main.async {
            // [앨범의 사진에 대한 접근 권한 확인 실시]
            PHPhotoLibrary.requestAuthorization( { status in
                switch status{
                case .authorized:
                    print("====================================")
                    print("[\(self.ACTIVITY_NAME) >> testMain() :: 앨범의 사진에 대한 접근 권한 확인 실시]")
                    print("상태 :: 앨범 권한 허용")
                    print("====================================")
                    // [앨범 열기 수행 실시]
                    self.openphoto()
                    break
                case .denied:
                    print("====================================")
                    print("[\(self.ACTIVITY_NAME) >> testMain() :: 앨범의 사진에 대한 접근 권한 확인 실시]")
                    print("상태 :: 앨범 권한 거부")
                    print("====================================")
                    break
                        
                case .notDetermined:
                    print("====================================")
                    print("[\(self.ACTIVITY_NAME) >> testMain() :: 앨범의 사진에 대한 접근 권한 확인 실시]")
                    print("상태 :: 앨범 권한 선택하지 않음")
                    print("====================================")
                    break
                        
                case .restricted:
                    print("====================================")
                    print("[\(self.ACTIVITY_NAME) >> testMain() :: 앨범의 사진에 대한 접근 권한 확인 실시]")
                    print("상태 :: 앨범 접근 불가능, 권한 변경이 불가능")
                    print("====================================")
                    break
                        
                default:
                    print("====================================")
                    print("[\(self.ACTIVITY_NAME) >> testMain() :: 앨범의 사진에 대한 접근 권한 확인 실시]")
                    print("상태 :: default")
                    print("====================================")
                    break
                }
            })
        }

    }
    func openphoto() {
        // [ImagePickerController 객체 생성 실시]
        let imagePicker = ImagePickerController()
        imagePicker.settings.theme.selectionStyle = .numbered // 이미지 선택 시 표시
        imagePicker.settings.theme.backgroundColor = .white // 배경 색상
        imagePicker.albumButton.tintColor = .mainColor // 버튼 색상
        imagePicker.cancelButton.tintColor = .mainColor // 버튼 색상
        imagePicker.doneButton.tintColor = .mainColor // 버튼 색상
        imagePicker.settings.theme.selectionFillColor = UIColor.mainColor! // 선택 배경 색상 (Circle)
        imagePicker.settings.theme.selectionStrokeColor = .white // 선택 표시 색상 (Circle)
        imagePicker.settings.selection.max = 5 // 최대 선택 개수
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
            print("선택한 이미지 개수 :: \(assets.count)")
            print("선택한 이미지 정보 :: \(assets.description)")
            
            // [선택한 이미지 사이즈 변환]
            if assets.count != 0 {
                if self.selectedImgs.count + assets.count > 5 {
                    self.VCfunc.showAlertAction1(vc: self, preferredStyle: .alert, title: "알림", message: "사진은 최대 5장까지 선택 가능합니다.")
                } else {
                    for i in 0..<assets.count {
                        let imageManager = PHImageManager.default()
                        let option = PHImageRequestOptions()
                        option.isSynchronous = true
                        var thumbnail = UIImage()
                            
                        imageManager.requestImage(for: assets[i],
                            targetSize: CGSize(width: 720, height: 720),
                            contentMode: .aspectFit,
                            options: option) { (result, info) in
                                thumbnail = result!
                            }
                                
                        let data = thumbnail.jpegData(compressionQuality: 1)
                        let newImage = UIImage(data: data!)
                                
                        // [이미지 뷰에 표시 실시]
                        //self.imageView.image = newImage! as UIImage
                        self.selectedImgs.append(newImage!)
                        var dataSize = data!.count
                        let dataSizeInKB = Double(dataSize) / 1024.0
                        print("Data size: \(dataSizeInKB) KB")
                        
                        
                        
                    }
                    self.collectionView.reloadData()
                    if let selectedCount = Int(self.imgCountLabel.text!) {
                        self.imgCountLabel.text = String(assets.count + selectedCount)
                    }
                }
                
            }
                
                
                    
        })
    }
        
        
}// .class

extension PetMemo_WriteViewController: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
            if contextTextView.text.isEmpty {
                contextTextView.text =  "내용을 입력하세요."
                contextTextView.textColor = UIColor.lightGray
            }

        }
        func textViewDidBeginEditing(_ textView: UITextView) {
            if contextTextView.textColor == UIColor.lightGray {
                contextTextView.text = nil
                contextTextView.textColor = UIColor.black
            }
        }
        

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let inputString = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let oldString = textView.text, let newRange = Range(range, in: oldString) else { return true }
        let newString = oldString.replacingCharacters(in: newRange, with: inputString).trimmingCharacters(in: .whitespacesAndNewlines)

        let characterCount = newString.count
        guard characterCount <= 100 else { return false }

        return true
    }
}

extension PetMemo_WriteViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
            return true
    }
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
            
    }
    // CollectionView item 개수
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    
        
        return selectedImgs.count
    }
    
    // CollectionView Cell의 Object
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MemoWriteImgCollectionViewCell", for: indexPath) as? MemoWriteImgCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.delegate = self
        cell.imageView.image = selectedImgs[indexPath.row]
        cell.indexPathRow = indexPath.row
    
        return cell
    }
    
    // CollectionView Cell의 Size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        //let width: CGFloat = collectionView.frame.width

        return CGSize(width: 92, height: 90)
    }
    
    // CollectionView Cell의 위아래 간격
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return 1.0
//    }
    
    // CollectionView Cell의 옆 간격
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.1
    }
    // 셀이 선택되었을 때
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.row)
        print(selectedImgs[indexPath.row])
        
        
        
    }
}
extension PetMemo_WriteViewController: UICollectionViewDropDelegate {
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        var destinationIndexPath: IndexPath
        if let indexPath = coordinator.destinationIndexPath {
            destinationIndexPath = indexPath
        } else {
            let row = collectionView.numberOfItems(inSection: 0)
            destinationIndexPath = IndexPath(item: row - 1, section: 0)
        }
        
        if coordinator.proposal.operation == .move {
            reorderItems(coordinator: coordinator, destinationIndexPath: destinationIndexPath, collectionView: collectionView)
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        if collectionView.hasActiveDrag {
            return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        }
        return UICollectionViewDropProposal(operation: .forbidden)
    }
    
    private func reorderItems(coordinator: UICollectionViewDropCoordinator, destinationIndexPath: IndexPath, collectionView: UICollectionView) {
        if
            let item = coordinator.items.first,
            let sourceIndexPath = item.sourceIndexPath {
            collectionView.performBatchUpdates({
                let temp = selectedImgs[sourceIndexPath.item]
                selectedImgs.remove(at: sourceIndexPath.item)
                selectedImgs.insert(temp, at: destinationIndexPath.item)
                collectionView.deleteItems(at: [sourceIndexPath])
                collectionView.insertItems(at: [destinationIndexPath])
            }) { done in
                //
            }
            coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
        }
    }
}

extension PetMemo_WriteViewController: UICollectionViewDragDelegate {
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        return []
    }
}


extension PetMemo_WriteViewController: MemoWriteImgCollectionViewCellDelegate{
    func didDeselectButtonClicked(at index: Int) {
        selectedImgs.remove(at: index)
        collectionView.reloadData()
        if let a = Int(imgCountLabel.text!) {
            if a > 0 {
                let beforeCnt = a - 1
                imgCountLabel.text = String(beforeCnt)
            }
        }
    }
}
