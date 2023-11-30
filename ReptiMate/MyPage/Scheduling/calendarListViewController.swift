//
//  calendarListViewController.swift
//  ReptiMate
//
//  Created by 김기용 on 2023/06/13.
//

import UIKit
import Alamofire
import FSCalendar

class calendarListViewController: UIViewController, LoadingScheduleTableViewCellDelegate, calendarListTableViewCellDelegate {
    let VCfunc: VCfunc = .init()
    var accessToken = ""
    var btn = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
    
    var totalListItem : [CalendarStructs] = []
    var ListItem : [CalendarStructs] = []
    var eventDate : [Date] = []
    var cellHeights: [IndexPath: CGFloat] = [:]
    var topHeight: CGFloat?
    
//    var page = 1
//    var size = 20
//    var order = "DESC"
//
//    var isPaging: Bool = false // 현재 페이징 중인지 체크하는 flag
//    var hasNextPage: Bool = false // 마지막 페이지 인지 체크 하는 flag
    
    let formatter = DateFormatter()
    var selectedDate: String = ""
    var todayDate: String = ""
    
    @IBOutlet weak var topMargin: NSLayoutConstraint!
    private var currentPage: Date?
    private lazy var today: Date = {
        return Date()
    }()
    
    private lazy var labelDateFormatter: DateFormatter = {
        let ldf = DateFormatter()
        ldf.locale = Locale(identifier: "ko_KR")
        ldf.dateFormat = "yyyy년 M월"
       return ldf
    }()
    
    @IBOutlet weak var calendarView: FSCalendar!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var leftMonthBtn: UIButton!
    @IBOutlet weak var rightMonthBtn: UIButton!
    
    @IBOutlet weak var monthLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        accessToken = UserDefaults.standard.string(forKey: "accessToken")!
        if accessToken == nil {
            navigationController?.popViewController(animated: true)
        }
        let nib = UINib(nibName: calendarListTableViewCell.identifier, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: calendarListTableViewCell.identifier)
        
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
        totalListItem = []
        eventDate = []
        tableView.reloadData()
        formatter.dateFormat = "yyyy-MM-dd"
        print("오늘은 : \(formatter.string(from: Date()))")
        selectedDate = formatter.string(from: Date())
        todayDate = formatter.string(from: Date())
        calendarListRequest(token: accessToken, date: formatter.string(from: Date()))
        setCalendar()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        btn.removeFromSuperview()
        if let isSelectedDate = calendarView.selectedDate {
            calendarView.deselect(isSelectedDate)
        }
        ListItem = []
        totalListItem = []
        eventDate = []
        tableView.reloadData()
        //planListRequest(token: accessToken, page: page, size: size, order: order)
    }
    func setCalendar() {
        calendarView.delegate = self
        calendarView.dataSource = self
        
        calendarView.locale = Locale(identifier: "ko_KR")
        
        // 헤더관련
        calendarView.calendarWeekdayView.weekdayLabels[0].text = "일"
        calendarView.calendarWeekdayView.weekdayLabels[1].text = "월"
        calendarView.calendarWeekdayView.weekdayLabels[2].text = "화"
        calendarView.calendarWeekdayView.weekdayLabels[3].text = "수"
        calendarView.calendarWeekdayView.weekdayLabels[4].text = "목"
        calendarView.calendarWeekdayView.weekdayLabels[5].text = "금"
        calendarView.calendarWeekdayView.weekdayLabels[6].text = "토"
        
        calendarView.headerHeight = 0
        monthLabel.text = self.labelDateFormatter.string(from:  calendarView.currentPage)
//        calendarView.appearance.headerDateFormat = "YYYY년 MM월"
//        calendarView.appearance.headerTitleColor = UIColor(named: "FFFFFF")?.withAlphaComponent(0.9)
//        calendarView.appearance.headerTitleAlignment = .center
//        calendarView.appearance.headerMinimumDissolvedAlpha = 0.0
        
        // 캘린더 관련
        calendarView.setScope(.month, animated: true)
        calendarView.appearance.selectionColor = .mainColor
        calendarView.appearance.todayColor = .white
        calendarView.appearance.titleTodayColor = .mainColor
        
        calendarView.appearance.eventDefaultColor = .mainColor
        calendarView.appearance.eventSelectionColor = .mainColor
        
        calendarView.scrollEnabled = false
        calendarView.scrollDirection = .horizontal
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
    @IBAction func prevBtnTapped(_ sender: Any) {
        if let isSelectedDate = calendarView.selectedDate {
            calendarView.deselect(isSelectedDate)
        }
        scrollCurrentPage(isPrev: true)
        ListItem = []
        totalListItem = []
        tableView.reloadData()
        calendarListRequest(token: accessToken, date: formatter.string(from: calendarView.currentPage))
        
    }
    @IBAction func nextBtnTapped(_ sender: Any) {
        if let isSelectedDate = calendarView.selectedDate {
            calendarView.deselect(isSelectedDate)
        }
        scrollCurrentPage(isPrev: false)
        ListItem = []
        totalListItem = []
        tableView.reloadData()
        calendarListRequest(token: accessToken, date: formatter.string(from: calendarView.currentPage))
        
    }
    private func scrollCurrentPage(isPrev: Bool) {
        let cal = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.month = isPrev ? -1 : 1
        
        self.currentPage = cal.date(byAdding: dateComponents, to: self.currentPage ?? self.today)
        self.calendarView.setCurrentPage(self.currentPage!, animated: true)
    }
    // =======
    // api 요청
    // =======
    @objc func buttonTapped() {
        // 버튼 클릭시 실행할 코드 작성
        guard let makeCalendarViewController = self.storyboard?.instantiateViewController(withIdentifier: "makeCalendarViewController") as? makeCalendarViewController  else { return }
        //makeCalendarViewController.delegate = self
        makeCalendarViewController.selectedDate = self.selectedDate
        
        self.navigationController?.pushViewController(makeCalendarViewController, animated: true)
    }
    func deleteButtonTapped(at indexPath: IndexPath?) {
        if let indexPath = indexPath {
            var idx = ""
            if let a = ListItem[indexPath.row].idx {
                idx = "\(a)"
            }
            for i in stride(from: 0, to: totalListItem.count, by: 1) {
                if totalListItem[i].idx == ListItem[indexPath.row].idx {
                    ListItem.remove(at: indexPath.row)
                    totalListItem.remove(at: i)
                }
            }
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.reloadData()
            let url = "https://api.reptimate.store/schedules/"+idx
            let header : HTTPHeaders = [
                        "Content-Type" : "multipart/form-data",
                        "Authorization" : "Bearer "+accessToken ]
            var params: [String : Any] = [:]
                //if (idx != "") { params.updateValue(idx.flatMap({ $0.description }) , forKey: "petIdx") }
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
    // 해당 월 달력 스케줄 조회
    func calendarListRequest(token: String?, date: String?) {
        self.formatter.dateFormat = "yyyy-MM-dd"
        let url = "https://api.reptimate.store/schedules/\(date ?? formatter.string(from: Date()))"
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
            .responseDecodable(of: CalendarListResponse.self) { response in
            switch response.result {
            case .success (let res):
                if response.value?.status == 200 {
                    if let getItem = res.result {
                        print(getItem)
                        self.totalListItem.append(contentsOf: getItem)
                        self.fetchSelectedDateList(targetDate: self.todayDate)
                        self.tableView.reloadData()
                        
                        let df = DateFormatter()
                        df.dateFormat = "yyyy-MM-dd"
                        for i in stride(from: 0, to: self.totalListItem.count, by: 1) {
                            if !self.eventDate.contains(df.date(from: self.totalListItem[i].date!)!) {
                                self.eventDate.append(df.date(from: self.totalListItem[i].date!)!)
                            }
                        }
                        self.calendarView.reloadData()
                    }
                } else if response.value?.status == 401 || response.value?.statusCode == 401{
                   //acessToken 재발급, 실패시 acessToken은 유지
                    self.VCfunc.getAccessToken() {
                        let newAccessToken = UserDefaults.standard.string(forKey: "accessToken")
                        if newAccessToken != self.accessToken {
                           self.accessToken = UserDefaults.standard.string(forKey: "accessToken")!
                           // 새로 발급받은 acessToken(newAccessToken)으로 api재시도
                           self.calendarListRequest(token: newAccessToken, date: date)
                        } else {
                           self.VCfunc.showAlertAction1(vc: self, preferredStyle: .alert, title: "로그인 만료", message: "다시 로그인 해주시기 바랍니다.")
                           if let navigationController = self.navigationController {
                               navigationController.popToRootViewController(animated: true)
                           }
                        }
                    }
                   
                } else if response.value?.status == 404 {
                    self.VCfunc.showAlertAction1(vc: self, preferredStyle: .alert, title: "알림", message: "회원 정보를 확인할 수 없습니다.\n다시 로그인 해주세요.")
                    UserDefaults.standard.removeObject(forKey: "accessToken")
                    UserDefaults.standard.removeObject(forKey: "refreshToken")
                    UserDefaults.standard.synchronize()
                    if let navigationController = self.navigationController {
                        navigationController.popToRootViewController(animated: true)
                    }
                } else if response.value?.status == 409 {
                    // 리스트 조회엔 409 없음
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
    func fetchSelectedDateList(targetDate: String?) {
        self.ListItem = []
        
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        for i in stride(from: 0, to: totalListItem.count, by: 1) {
            if totalListItem[i].date == targetDate {
                self.ListItem.append(totalListItem[i])
//                if let date = df.date(from: targetDate!) {
//                    self.eventDate.append(date)
//                }
            }
            if self.ListItem.count == 0 {
                self.tableView.setEmptyMessage("등록된 일정이 없습니다. \n우측 하단 버튼을 통해 등록해주세요!")
            } else {
                self.tableView.restore()
            }
        }
        self.tableView.reloadData()
    }
    
    
}
extension calendarListViewController: UITableViewDelegate, UITableViewDataSource {
    // Section을 2개 설정하는 이유는 페이징 로딩 시 로딩 셀을 표시
    // 이 페이지에서는 페이징이 적용되지 않기 때문에 1로 반환
        func numberOfSections(in tableView: UITableView) -> Int {
            return 1
        }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = ListItem[indexPath.row]
        
        guard let editViewController = self.storyboard?.instantiateViewController(withIdentifier: "makeCalendarViewController") as? makeCalendarViewController  else { return }
        editViewController.scheduleInfo = item.self
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
        
        
        return ListItem.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: calendarListTableViewCell.identifier, for: indexPath) as? calendarListTableViewCell else { return UITableViewCell() }
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

// 달력 스케줄 하단의 목록은 페이징 적용 안함
extension calendarListViewController {
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let offsetY = scrollView.contentOffset.y
//        let contentHeight = scrollView.contentSize.height
//        let height = scrollView.frame.height
//
//        // 스크롤이 테이블 뷰 Offset의 끝에 가게 되면 다음 페이지를 호출
//        if offsetY > (contentHeight - height) {
//            if isPaging == false && hasNextPage {
//                beginPaging()
//            }
//        }
//    }
//    func beginPaging() {
//        isPaging = true // 현재 페이징이 진행 되는 것을 표시
//        // Section 1을 reload하여 로딩 셀을 보여줌 (페이징 진행 중인 것을 확인할 수 있도록)
//        DispatchQueue.main.async {
//            self.tableView.reloadSections(IndexSet(integer: 1), with: .none)
//        }
//        // 페이징 메소드 호출
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//            //self.petListRequest(token: self.accessToken, page: self.page, size: self.size, order: self.order)
//        }
//    }
}
extension calendarListViewController : FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    
    
    
    
    // 날짜 선택 시 콜백 메소드
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        formatter.dateFormat = "yyyy-MM-dd"
        self.selectedDate = formatter.string(from: date)
        self.fetchSelectedDateList(targetDate: self.selectedDate)
        self.tableView.reloadData()
        print(formatter.string(from: date) + " 선택됨")
        print("ListItem : \(self.ListItem)")
        
        let todayis = Date() // 현재의 날짜와 시간을 가져옵니다.

        let dfr = DateFormatter()
        dfr.locale = Locale(identifier: "ko_KR") // 로케일을 한국으로 설정합니다.
        dfr.dateFormat = "yyyy-MM-dd" // 날짜의 형식을 지정합니다.

        let todayisString = dfr.string(from: todayis)
        let formattedDate = dfr.date(from: todayisString)
        
        if date < formattedDate! {
            self.btn.isHidden = true
        } else {
            self.btn.isHidden = false
        }
        
    }
    // 날짜 선택 해제 시 콜백 메소드
    public func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
        //keywordForCV = []
        self.selectedDate = ""
        //print(formatter.string(from: date) + " 해제됨")
    }
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        if self.eventDate.contains(date) {
            return 1
        }
        return 0
    }
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        self.monthLabel.text = self.labelDateFormatter.string(from: calendar.currentPage)
    }
    
    
    
}
