//
//  planListViewController.swift
//  ReptiMate
//
//  Created by 김기용 on 2023/06/13.
//

import UIKit
import Alamofire

class planListViewController: UIViewController, planListTableViewCellDelegate, LoadingScheduleTableViewCellDelegate {
    
    let VCfunc: VCfunc = .init()
    var accessToken = ""
    var btn = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
    
    var ListItem : [ScheduleStructs] = []
    var cellHeights: [IndexPath: CGFloat] = [:]
    var topHeight: CGFloat?
    
    var page = 1
    var size = 20
    var order = "ASC"
    
    var isPaging: Bool = false // 현재 페이징 중인지 체크하는 flag
    var hasNextPage: Bool = false // 마지막 페이지 인지 체크 하는 flag
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topMargin: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        accessToken = UserDefaults.standard.string(forKey: "accessToken")!
        if accessToken == nil {
            navigationController?.popViewController(animated: true)
        }
        let nib = UINib(nibName: planListTableViewCell.identifier, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: planListTableViewCell.identifier)
        
        let nibLoading = UINib(nibName: LoadingScheduleTableViewCell.identifier, bundle: nil)
        tableView.register(nibLoading, forCellReuseIdentifier: LoadingScheduleTableViewCell.identifier)
        
        tableView.dataSource = self
        tableView.delegate = self
        topMargin.constant = (topHeight ?? 100) + 10
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setBtn()
        ListItem = []
        tableView.reloadData()
        planListRequest(token: accessToken, page: page, size: size, order: order)
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        btn.removeFromSuperview()
        page = 1
        size = 20
        order = "ASC"
        ListItem = []
        tableView.reloadData()
        //planListRequest(token: accessToken, page: page, size: size, order: order)
    }
    
    func setBtn() {
        btn.backgroundColor = .mainColor
        btn.layer.cornerRadius = btn.frame.width / 2
        btn.setTitle("+", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 30)
        btn.setTitleColor(.white, for: .normal)
                
        view.addSubview(btn)
        btn.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            btn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -22),
            btn.bottomAnchor.constraint(equalTo: tableView.bottomAnchor, constant: -25),
            btn.widthAnchor.constraint(equalToConstant: 60),
            btn.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: btn.frame.height, right: 0)
        
        btn.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    @objc func buttonTapped() {
        // 버튼 클릭시 실행할 코드 작성
        guard let makePlanViewController = self.storyboard?.instantiateViewController(withIdentifier: "makePlanViewController") as? makePlanViewController  else { return }
        //Home_MyPageViewController.delegate = self
        
        self.navigationController?.pushViewController(makePlanViewController, animated: true)
    }
    func deleteButtonTapped(at indexPath: IndexPath?) {
        if let indexPath = indexPath {
            var idx = ""
            if let a = ListItem[indexPath.row].idx {
                idx = "\(a)"
            }
            ListItem.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.reloadData()
            
            let url = "https://api.reptimate.store/schedules/"+idx

                let header : HTTPHeaders = [
                            "Content-Type" : "multipart/form-data",
                            "Authorization" : "Bearer "+accessToken ]
                    
                var params: [String : Any] = [:]

                AF.upload(multipartFormData: { multipartFormData in
                           for (key, value) in params {
                               multipartFormData.append("\(value)".data(using: .utf8)!, withName: key)
                           }
                       }, to: url, method: .delete, headers: header)
                
                .responseDecodable(of: messageResponse.self) { response in
                        switch response.result {
                        case .success:
                            
                            if response.value?.status == 200 {
//                                self.VCfunc.showAlertAction1(vc: self, preferredStyle: .alert, title: "알림", message: "삭제 되었습니다.")
                            } else if response.value?.status == 401 || response.value?.statusCode == 401{
                                //acessToken 재발급, 실패시 acessToken은 유지
                                self.VCfunc.getAccessToken() {
                                    let newAccessToken = UserDefaults.standard.string(forKey: "accessToken")
                                    if newAccessToken != self.accessToken {
                                       self.accessToken = UserDefaults.standard.string(forKey: "accessToken")!
                                       // 새로 발급받은 acessToken(newAccessToken)으로 api재시도
                                       self.deleteButtonTapped(at: indexPath)
                                    } else {
                                       self.VCfunc.showAlertAction1(vc: self, preferredStyle: .alert, title: "로그인 만료", message: "다시 로그인 해주시기 바랍니다.")
                                       if let navigationController = self.navigationController {
                                           navigationController.popToRootViewController(animated: true)
                                       }
                                    }
                                }
                                
                            } else if  response.value?.status == 404 {
                                self.VCfunc.showAlertAction1(vc: self, preferredStyle: .alert, title: "알림", message: "해당 스케줄이 존재하지 않습니다.")
                            } else if  response.value?.status == 409 {
                                
                            } else {
                                print(response.value)
                                self.VCfunc.showAlertAction1(vc: self, preferredStyle: .alert, title: "알림", message: "서버와의 통신에 오류가 발생하였습니다.")
                            }
                            break
                        case .failure(let error):
                            print(" Request Error\nCode:\(error._code), Message: \(error.errorDescription!)")
                            self.VCfunc.showAlertAction1(vc: self, preferredStyle: .alert, title: "알림", message: "서버와의 통신에 오류가 발생하였습니다.")
                        }
                }
            }
    }
    // =======
    // api 요청
    // =======
    func planListRequest(token: String?, page: Int, size: Int, order: String) {
        let url = "https://api.reptimate.store/schedules?page=\(page)&size=\(size)&order=\(order)"
        LoadingService.showLoading()
        print(url)
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
            .responseDecodable(of: SimpleResponse<ScheduleListResponse>.self) { response in
            switch response.result {
            case .success (let res):
                if response.value?.status == 200 {
                    let responseJson = try? JSONEncoder().encode(res.result)
                    let resultJson = try? JSONDecoder().decode(ScheduleListResponse.self, from: responseJson!)
                    
                    let next = resultJson?.existsNextPage
                    self.hasNextPage = next!
                    
                    if self.hasNextPage == true {
                        self.page += 1
                    }

                    print(resultJson?.items)
                    if let getItem = resultJson?.items {
                        self.ListItem.append(contentsOf: getItem)
                        self.isPaging = false
                        self.tableView.reloadData()
                    }
                } else if response.value?.status == 401 || response.value?.statusCode == 401 {
                   //acessToken 재발급, 실패시 acessToken은 유지
                    self.VCfunc.getAccessToken() {
                        let newAccessToken = UserDefaults.standard.string(forKey: "accessToken")
                        if newAccessToken != self.accessToken {
                           self.accessToken = UserDefaults.standard.string(forKey: "accessToken")!
                           // 새로 발급받은 acessToken(newAccessToken)으로 api재시도
                           self.planListRequest(token: newAccessToken, page: page, size: size, order: order)
                        } else {
                           self.VCfunc.showAlertAction1(vc: self, preferredStyle: .alert, title: "로그인 만료", message: "다시 로그인 해주시기 바랍니다.")
                           if let navigationController = self.navigationController {
                               navigationController.popToRootViewController(animated: true)
                           }
                        }
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
    
    
    

} // planListViewController.class

extension planListViewController: UITableViewDelegate, UITableViewDataSource {
    // Section을 2개 설정하는 이유는 페이징 로딩 시 로딩 셀을 표시
        func numberOfSections(in tableView: UITableView) -> Int {
            return 2
        }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = ListItem[indexPath.row]
        
        guard let editViewController = self.storyboard?.instantiateViewController(withIdentifier: "makePlanViewController") as? makePlanViewController  else { return }
        
        editViewController.scheduleInfo = item
        editViewController.isEdit = true
        
        self.navigationController?.pushViewController(editViewController, animated: true)
        
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
            // 해당 indexPath에 높이값이 있다면 높이값을 반환하고 없으면 기본 값을 반환하도록 함
            return cellHeights[indexPath] ?? 80
        }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
            // 셀의 데이터 세팅이 완료 된 후 실제 높이 값을
            cellHeights[indexPath] = cell.frame.size.height
        }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if ListItem.count == 0 {
            self.tableView.setEmptyMessage("등록된 일정이 없습니다. \n우측 하단 버튼을 통해 등록해 주세요!")
        } else {
            self.tableView.restore()
        }
        
        
        if section == 0 {
                    return ListItem.count
                } else if section == 1 && isPaging && hasNextPage {
                    return 1
                }
                
                return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: planListTableViewCell.identifier, for: indexPath) as? planListTableViewCell else { return UITableViewCell() }
            cell.delegate = self
            
            cell.setData(ListItem[indexPath.row])
            cell.scheduleInfo = ListItem[indexPath.row]
            cell.token = self.accessToken
            
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: LoadingScheduleTableViewCell.identifier, for: indexPath) as? LoadingScheduleTableViewCell else { return UITableViewCell() }
                        
            cell.start()
                        
            return cell
        }
    }
}


extension planListViewController {
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
            self.tableView.reloadSections(IndexSet(integer: 1), with: .none)
        }
        
        // 페이징 메소드 호출
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//            self.petListRequest(token: self.accessToken, page: self.page, size: self.size, order: self.order)
//        }
    }
}
