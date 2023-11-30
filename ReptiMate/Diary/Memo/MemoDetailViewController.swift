//
//  MemoDetailViewController.swift


import UIKit
import Alamofire

// 메모 상세보기 VC
class MemoDetailViewController: UIViewController, editProtocol {
    func dataSend(data: String) {
        if data.lengthOfBytes(using: String.Encoding.utf8) > 0 {
            imgList = []
            imgItemList = []
            collectionView.reloadData()
            
            petListRequest(token: accessToken, diaryIdx: diaryIdx!, petIdx: (petInfo?.idx)!)
        }
    }
    
    
    let VCfunc: VCfunc = .init()
    
    var accessToken = ""
    var petInfo: petListItem?
    var petMemoDetail: MemoDetailResponse?
    var diaryIdx: Int?
    var imgItemList: [petMemoDetailImgItem] = []
    var imgList: [UIImage] = []
    
    var isEdited = false
    
    @IBOutlet weak var backBtn: UIButton!
    
    @IBOutlet weak var memoTitleLabel: UILabel!
    
    @IBOutlet weak var memoDateLabel: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var contentTextView: UITextView!
    
    @IBOutlet weak var moreBtn: UIButton!
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var collectionSuperView: UIView!
    
    var collectionViewHeight: NSLayoutConstraint!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.swipeRecognizer()
        accessToken = UserDefaults.standard.string(forKey: "accessToken")!
        if accessToken == nil {
            navigationController?.popViewController(animated: true)
        }
        
        contentTextView.isEditable = false
        
        collectionView?.delegate = self
        collectionView?.dataSource = self
        
        collectionViewHeight = collectionSuperView.heightAnchor.constraint(equalToConstant: 0)
        collectionViewHeight.isActive = true
        
        let edit = UIAction(title: "수정", handler: { _ in
            print("수정")
            guard let PetMemo_WriteViewController = self.storyboard?.instantiateViewController(withIdentifier: "PetMemo_WriteViewController") as? PetMemo_WriteViewController  else { return }
            // delegate
            PetMemo_WriteViewController.petMemoDetail = self.petMemoDetail
            PetMemo_WriteViewController.isEdit = true
            PetMemo_WriteViewController.imgList = self.imgItemList
            PetMemo_WriteViewController.delegate = self
            self.navigationController?.pushViewController(PetMemo_WriteViewController, animated: true)
        })
        let delete = UIAction(title: "삭제", attributes: .destructive, handler: { _ in
            print("취소")
            self.deleteMemo(token: self.accessToken, diaryIdx: self.diaryIdx!)
        })
        let buttonMenu = UIMenu(children: [edit, delete])
        moreBtn.menu = buttonMenu
        
        imgList = []
        imgItemList = []
        collectionView.reloadData()
        
        petListRequest(token: accessToken, diaryIdx: diaryIdx!, petIdx: (petInfo?.idx)!)
        
    }// didload
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }// willappear
    
    @IBAction func backBtnPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    

    // =======
    // api 요청
    // =======
    // 메모 불러오기
    func petListRequest(token: String?, diaryIdx: Int, petIdx: Int) {
        let url = "https://api.reptimate.store/diaries/\(petIdx)/\(diaryIdx)"
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
            .responseDecodable(of: SimpleResponse<MemoDetailResponse>.self) { response in
            switch response.result {
            case .success (let res):
                if response.value?.status == 200 {
                    let responseJson = try? JSONEncoder().encode(res.result)
                    let resultJson = try? JSONDecoder().decode(MemoDetailResponse.self, from: responseJson!)
                    
                    self.petMemoDetail = resultJson
                    guard let getTitle = resultJson?.title else { return }
                    self.memoTitleLabel.text = getTitle
                    guard let getContent = resultJson?.content else { return }
                    self.contentTextView.text = getContent
                    
                    var memoWritten = resultJson?.createdAt?.split(separator: "T")
                    self.memoDateLabel.text = String(memoWritten![0])
                    
                    DispatchQueue.main.async {
                        
                        if let getItem = resultJson?.images {
                            self.collectionViewHeight.isActive = false
                            self.imgItemList.append(contentsOf: getItem)
                            
                            
                            if self.imgItemList.isEmpty {
                                self.collectionViewHeight.isActive = true
                            }
                            
                            let dispatchGroup = DispatchGroup()
                            for i in stride(from: 0, to: self.imgItemList.count, by: 1) {
                                dispatchGroup.enter()
                                UIImage.getImageFromUrl(self.imgItemList[i].imagePath!) { image in
                                    if let image = image {
                                        self.imgList.append(image)
                                    } else {
                                    }
                                    dispatchGroup.leave()
                                }
                            }
                            dispatchGroup.notify(queue: .main) {
                                self.pageControl.numberOfPages = self.imgItemList.count
                                self.pageControl.currentPage = 0
                                self.pageControl.hidesForSinglePage = true
                                self.view.bringSubviewToFront(self.pageControl)
                                self.collectionView.reloadData()
                            }
                        }
                        
                    }
                    
                    
                } else if response.value?.status == 401 || response.value?.statusCode == 401{
                   //acessToken 재발급, 실패시 acessToken은 유지
                    self.VCfunc.getAccessToken() {
                        let newAccessToken = UserDefaults.standard.string(forKey: "accessToken")
                        if newAccessToken != self.accessToken {
                           self.accessToken = UserDefaults.standard.string(forKey: "accessToken")!
                           // 새로 발급받은 acessToken(newAccessToken)으로 api재시도
                           self.petListRequest(token: newAccessToken, diaryIdx: diaryIdx, petIdx: petIdx)
                        } else {
                           self.VCfunc.showAlertAction1(vc: self, preferredStyle: .alert, title: "로그인 만료", message: "다시 로그인 해주시기 바랍니다.")
                           if let navigationController = self.navigationController {
                               navigationController.popToRootViewController(animated: true)
                           }
                        }
                    }
                   
                } else if response.value?.status == 404 {
                    switch response.value?.errorCode {
                    case "CANNOT_FIND_PET":
                        self.VCfunc.showAlertAction1(vc: self, preferredStyle: .alert, title: "알림", message: "등록한 반려동물 정보를 찾을 수 없습니다.")
                        self.navigationController?.popViewController(animated: true)
                    case "CANNOT_FIND_DIARY":
                        self.VCfunc.showAlertAction1(vc: self, preferredStyle: .alert, title: "알림", message: "등록한 메모를 찾을 수 없습니다..")
                        self.navigationController?.popViewController(animated: true)
                    case .none: break
                    case .some(_): break
                    }
                } else if response.value?.status == 409 {
                    
                } else if response.value?.status == 422 {
                    self.VCfunc.showAlertAction1(vc: self, preferredStyle: .alert, title: "알림", message: "입력란을 다시 확인해 주세요.")
                }
                break
            case .failure(let error):
                print("Request Error\nCode:\(error._code), Message: \(error.errorDescription!)")
                
            }
        }

    }
    func deleteMemo(token: String?, diaryIdx: Int) {
        let url = "https://api.reptimate.store/diaries/\(diaryIdx)"
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer "+token! , forHTTPHeaderField: "Authorization")

        // POST 로 보낼 정보
        AF.request(url,
                method: .delete,
                parameters: nil,
                encoding: URLEncoding.default,
                   headers: ["Content-Type":"application/json", "Accept":"application/json", "Authorization":"Bearer "+token!])
            .responseDecodable(of: messageResponse.self) { response in
            switch response.result {
            case .success (let res):
                
                if response.value?.status == 200 {
                    print("메모 삭제 완료")
                    self.navigationController?.popViewController(animated: true)
                } else if response.value?.status == 401 || response.value?.statusCode == 401{
                    //acessToken 재발급, 실패시 acessToken은 유지
                    self.VCfunc.getAccessToken() {
                        let newAccessToken = UserDefaults.standard.string(forKey: "accessToken")
                        if newAccessToken != self.accessToken {
                           self.accessToken = UserDefaults.standard.string(forKey: "accessToken")!
                           // 새로 발급받은 acessToken(newAccessToken)으로 api재시도
                           self.deleteMemo(token: newAccessToken, diaryIdx: diaryIdx)
                        } else {
                           self.VCfunc.showAlertAction1(vc: self, preferredStyle: .alert, title: "로그인 만료", message: "다시 로그인 해주시기 바랍니다.")
                           if let navigationController = self.navigationController {
                               navigationController.popToRootViewController(animated: true)
                           }
                        }
                    }
                    
                } else if  response.value?.status == 404 {
                    self.VCfunc.showAlertAction1(vc: self, preferredStyle: .alert, title: "알림", message: "메모를 찾을 수 없습니다.")
                    self.navigationController?.popViewController(animated: true)
                } else if  response.value?.status == 409 {
                    
                } else {
                    print(response.value?.message)
                    self.VCfunc.showAlertAction1(vc: self, preferredStyle: .alert, title: "알림", message: "서버와의 통신에 오류가 발생하였습니다.")
                }
                break
            case .failure(let error):
                print("Request Error\nCode:\(error._code), Message: \(error.errorDescription!)")
                
            }
        }
    }
    

}// MemoDetailViewController.class

extension MemoDetailViewController: UIScrollViewDelegate {
    
}

extension MemoDetailViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let width = scrollView.bounds.size.width
        // 좌표보정을 위해 절반의 너비를 더해줌
        let x = scrollView.contentOffset.x + (width/2)
        
        let newPage = Int(x / width)
        if pageControl.currentPage != newPage {
            pageControl.currentPage = newPage
        }
    }
    
    // CollectionView item 개수
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imgItemList.count
    }
    
    // CollectionView Cell의 Object
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MemoDetailCollectionViewCell", for: indexPath) as! MemoDetailCollectionViewCell
        
        cell.setData(imgList[indexPath.row])
        
        return cell
    }
    
    // CollectionView Cell의 Size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return collectionView.frame.size
        
    }
    
    // CollectionView Cell의 위아래 간격
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return 1.0
//    }
    
//    // CollectionView Cell의 옆 간격
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        return 1.0
//    }
    
    // 셀이 선택되었을 때
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let MemoDetailImgViewController = self.storyboard?.instantiateViewController(withIdentifier: "MemoDetailImgViewController") as? MemoDetailImgViewController  else { return }
        // delegate
        MemoDetailImgViewController.firstIdx = indexPath.row
        MemoDetailImgViewController.totalCnt = imgList.count
        MemoDetailImgViewController.imgList = self.imgList
        
        self.navigationController?.pushViewController(MemoDetailImgViewController, animated: true)
        
        
    }
    
    
    
    
    
    
}
