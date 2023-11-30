//
//  Diary_PetDiaryTabViewController.swift
//  ReptiMate
//
//  Created by 김기용 on 2023/05/03.
//

import UIKit
import Alamofire

class Diary_PetMemoTabViewController: UIViewController, CollectionViewLoadingCellDelegate {
    let VCfunc: VCfunc = .init()
    
    var petInfo:petListItem?
    var topHeight: CGFloat?
    var petMemoList:[petMemoItem] = []
    
    var accessToken = ""
    
    @IBOutlet weak var topMargin: NSLayoutConstraint!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var btn = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
     
    var page = 1
    var size = 20
    var order = "DESC"
    
    var isPaging: Bool = false // 현재 페이징 중인지 체크하는 flag
    var hasNextPage: Bool = false // 마지막 페이지 인지 체크 하는 flag
    
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        accessToken = UserDefaults.standard.string(forKey: "accessToken")!
        if accessToken == nil {
            navigationController?.popViewController(animated: true)
            print(accessToken)
        }
        
//        let nib = UINib(nibName: "MemoListCollectionViewCell", bundle: nil)
//        collectionView.register(nib, forCellWithReuseIdentifier: "MemoListCollectionViewCell")
        let nibLoading = UINib(nibName: "CollectionViewLoadingCell", bundle: nil)
        collectionView.register(nibLoading, forCellWithReuseIdentifier: CollectionViewLoadingCell.identifier)
        
        collectionView?.delegate = self
        collectionView?.dataSource = self
        
        btn.backgroundColor = .mainColor
        btn.layer.cornerRadius = btn.frame.width / 2
        btn.setTitle("+", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 30)
        btn.setTitleColor(.white, for: .normal)
        view.addSubview(btn)
        btn.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            btn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -22),
            btn.bottomAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: -25),
            btn.widthAnchor.constraint(equalToConstant: 60),
            btn.heightAnchor.constraint(equalToConstant: 60)
        ])
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: btn.frame.height, right: 0)
        btn.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)

        topMargin.constant = topHeight ?? 260
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()

        if collectionView.contentSize.height > collectionView.frame.height {
            collectionView.isScrollEnabled = true
        } else {
            collectionView.isScrollEnabled = false
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        page = 1
        size = 20
        order = "DESC"
        isPaging = false // 현재 페이징 중인지 체크하는 flag
        hasNextPage = false // 마지막 페이지 인지 체크 하는 flag
        petMemoList = []
        collectionView.reloadData()
        petListRequest(token: accessToken, page: page, size: size, order: order, idx: (petInfo?.idx)!)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        petMemoList = []
        collectionView.reloadData()
    }
    
    @objc func buttonTapped() {
        // 버튼 클릭시 실행할 코드 작성
        guard let petMemo_WriteViewController = self.storyboard?.instantiateViewController(withIdentifier: "PetMemo_WriteViewController") as? PetMemo_WriteViewController  else { return }
        //delegate
        petMemo_WriteViewController.petInfo = self.petInfo
        self.navigationController?.pushViewController(petMemo_WriteViewController, animated: true)
    }
    
    // =======
    // api 요청
    // =======
    // 메모 리스트 불러오기
    func petListRequest(token: String?, page: Int, size: Int, order: String, idx: Int) {
        LoadingService.showLoading()
        let url = "https://api.reptimate.store/diaries/\(idx)?page=\(page)&size=\(size)&order=\(order)"
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
            .responseDecodable(of: SimpleResponse<petMemoResponse>.self) { response in
            switch response.result {
            case .success (let res):
                if response.value?.status == 200 {
                    let responseJson = try? JSONEncoder().encode(res.result)
                    let resultJson = try? JSONDecoder().decode(petMemoResponse.self, from: responseJson!)
                    
                    let next = resultJson?.existsNextPage
                    self.hasNextPage = next!
                    // 페이징 확인 후 리스트에 반영
                    if self.hasNextPage == true {
                        self.page += 1
                    }
                    DispatchQueue.main.async {
                        if let getItem = resultJson?.items {
                            self.petMemoList.append(contentsOf: getItem)
                            self.isPaging = false
                            self.collectionView.reloadData()
                        }
                    }
                } else if response.value?.status == 401 || response.value?.statusCode == 401{
                   //acessToken 재발급, 실패시 acessToken은 유지
                    self.VCfunc.getAccessToken() {
                        let newAccessToken = UserDefaults.standard.string(forKey: "accessToken")
                        if newAccessToken != self.accessToken {
                           self.accessToken = UserDefaults.standard.string(forKey: "accessToken")!
                           // 새로 발급받은 acessToken(newAccessToken)으로 api재시도
                           self.petListRequest(token: newAccessToken, page: page, size: size, order: order, idx: idx)
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
                        self.VCfunc.showAlertAction1(vc: self, preferredStyle: .alert, title: "알림", message: "등록한 메모를 찾을 수 없습니다.")
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
                LoadingService.hideLoading()
        }

    }
   
    
}
extension Diary_PetMemoTabViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    // CollectionView item 개수
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if petMemoList.count == 0 {
            self.collectionView.setEmptyMessage("작성된 메모가 없습니다. \n우측 하단 버튼을 통해 등록해 주세요!")
        } else {
            self.collectionView.restore()
        }
        
        if section == 0 {
                    return petMemoList.count
                } else if section == 1 && isPaging && hasNextPage {
                    return 1
                }
                
                return 0
        
    }
    
    // CollectionView Cell의 Object
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MemoListCollectionViewCell", for: indexPath) as! MemoListCollectionViewCell
            
            cell.memoInfo = petMemoList[indexPath.row]
            cell.setData(petMemoList[indexPath.row])
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewLoadingCell", for: indexPath) as! CollectionViewLoadingCell
            cell.start()
            return cell
        }
        
        
    }
    
    // CollectionView Cell의 Size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width: CGFloat = collectionView.frame.width

        return CGSize(width: width, height: 90)
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
        guard let MemoDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "MemoDetailViewController") as? MemoDetailViewController  else { return }
        // delegate
        MemoDetailViewController.petInfo = self.petInfo
        MemoDetailViewController.diaryIdx = petMemoList[indexPath.row].idx
        self.navigationController?.pushViewController(MemoDetailViewController, animated: true)
        
        
        
    }
}
extension Diary_PetMemoTabViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.height
        
        // 스크롤이 테이블 뷰 Offset의 끝에 가게 되면 다음 페이지를 호출
        if offsetY > (contentHeight - height) {
            if isPaging == false && hasNextPage {
                beginPaging()
            }
        }
    }
    
    func beginPaging() {
        isPaging = true // 현재 페이징이 진행 되는 것을 표시
        // Section 1을 reload하여 로딩 셀을 보여줌 (페이징 진행 중인 것을 확인할 수 있도록)
        DispatchQueue.main.async {
            self.collectionView.reloadSections(IndexSet(integer: 1))
        }
        
        // 페이징 메소드 호출
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.petListRequest(token: self.accessToken, page: self.page, size: self.size, order: self.order, idx: (self.petInfo?.idx)!)
        }
    }
}
