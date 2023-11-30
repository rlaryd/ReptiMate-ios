//
//  Diary_PetWeightTabViewController.swift
//  ReptiMate
//
//  Created by 김기용 on 2023/05/03.
//

import UIKit
import Alamofire
import Charts

class Diary_PetWeightTabViewController: UIViewController, DataUpdateDelegate, WeightTableViewCellDelegate {
      
    var petInfo: petListItem?
    
    let VCfunc: VCfunc = .init()
    var accessToken = ""
    var doRefresh = ""
    
    var topHeight: CGFloat?
     
    var page = 1
    var size = 20
    var order = "DESC"
    var chartType = "week"
    
    var isPaging: Bool = false // 현재 페이징 중인지 체크하는 flag
    var hasNextPage: Bool = false // 마지막 페이지 인지 체크 하는 flag
    
    @IBOutlet weak var topMargin: NSLayoutConstraint!
    @IBOutlet weak var writeWeightBtnView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lineChartView: LineChartView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var nowWeightLabel: UILabel!
    
    @IBOutlet weak var chartWeeklyBtn: UIButton!
    @IBOutlet weak var chartMonthlyBtn: UIButton!
    @IBOutlet weak var chartYearlyBtn: UIButton!
    
    var ListItem : [petWeightDetailItem] = []
    var cellHeights: [IndexPath: CGFloat] = [:]
    
    var dateData: [String] = []
    var weightData: [Double] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        accessToken = UserDefaults.standard.string(forKey: "accessToken")!
        if accessToken == nil {
            navigationController?.popViewController(animated: true)
        }
        
        let nib = UINib(nibName: WeightTableViewCell.identifier, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: WeightTableViewCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        
        let showDialog = UITapGestureRecognizer(target: self, action: #selector(weightDialog))
        writeWeightBtnView.isUserInteractionEnabled = true
        writeWeightBtnView.addGestureRecognizer(showDialog)
                
        setBtnInit()
        
        topMargin.constant = topHeight ?? 260
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("Diary_PetWeightTabViewController : viewWillAppear")
        chartWeeklyBtn.tintColor = .clear
        page = 1
        size = 20
        order = "default"
        isPaging = false // 현재 페이징 중인지 체크하는 flag
        hasNextPage = false // 마지막 페이지 인지 체크 하는 flag
        ListItem = []
        //tableView.reloadData()
        chartType = "week"
        petWeightListRequest(token: accessToken, page: page, size: size, order: order, idx: (petInfo?.idx)!)
        petWeightChartListRequest(token: accessToken, order: chartType, idx: (petInfo?.idx)!)
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("Diary_PetWeightTabViewController : viewDidDisappear")
        ListItem = []
        tableView.reloadData()
    }
    
    @IBAction func chartTypePressed(_ sender: UIButton) {
        if sender == chartWeeklyBtn {
            if chartWeeklyBtn.isSelected {
                
            } else {
                chartType = "week"
                chartWeeklyBtn.layer.borderColor = UIColor.mainColor?.cgColor
                chartMonthlyBtn.layer.borderColor = UIColor.lightGray.cgColor
                chartYearlyBtn.layer.borderColor = UIColor.lightGray.cgColor
                chartWeeklyBtn.isSelected = true
                chartMonthlyBtn.isSelected = false
                chartYearlyBtn.isSelected = false
                petWeightChartListRequest(token: accessToken, order: chartType, idx: (petInfo?.idx)!)
                DispatchQueue.main.async {
                    self.customizeChart()
                    if self.lineChartView.data?.count == 0 {
                        self.lineChartView.noDataText = "등록된 데이터가 없습니다"
                        self.lineChartView.noDataFont = .systemFont(ofSize: 20)
                        self.lineChartView.noDataTextColor = .lightGray // 데이터가 없을 때 표시할 텍스트 설정
                    }
                }
            }
        } else if sender == chartMonthlyBtn {
            if chartMonthlyBtn.isSelected {
                
            } else {
                chartType = "month"
                chartWeeklyBtn.layer.borderColor = UIColor.lightGray.cgColor
                chartMonthlyBtn.layer.borderColor = UIColor.mainColor?.cgColor
                chartYearlyBtn.layer.borderColor = UIColor.lightGray.cgColor
                chartWeeklyBtn.isSelected = false
                chartMonthlyBtn.isSelected = true
                chartYearlyBtn.isSelected = false
                petWeightChartListRequest(token: accessToken, order: chartType, idx: (petInfo?.idx)!)
                DispatchQueue.main.async {
                    self.customizeChart()
                    if self.lineChartView.data?.count == 0 {
                        self.lineChartView.noDataText = "등록된 데이터가 없습니다"
                        self.lineChartView.noDataFont = .systemFont(ofSize: 20)
                        self.lineChartView.noDataTextColor = .lightGray // 데이터가 없을 때 표시할 텍스트 설정
                    }
                }
            }
        } else if sender == chartYearlyBtn {
            if chartYearlyBtn.isSelected {
                
            } else {
                chartType = "year"
                chartWeeklyBtn.layer.borderColor = UIColor.lightGray.cgColor
                chartMonthlyBtn.layer.borderColor = UIColor.lightGray.cgColor
                chartYearlyBtn.layer.borderColor = UIColor.mainColor?.cgColor
                chartWeeklyBtn.isSelected = false
                chartMonthlyBtn.isSelected = false
                chartYearlyBtn.isSelected = true
                petWeightChartListRequest(token: accessToken, order: chartType, idx: (petInfo?.idx)!)
                DispatchQueue.main.async {
                    self.customizeChart()
                    if self.lineChartView.data?.count == 0 {
                        self.lineChartView.noDataText = "등록된 데이터가 없습니다"
                        self.lineChartView.noDataFont = .systemFont(ofSize: 20)
                        self.lineChartView.noDataTextColor = .lightGray // 데이터가 없을 때 표시할 텍스트 설정
                    }
                }
            }
        }
    }

    // ============
    // 그래프 관련 함수
    func customizeChart() {
        self.lineChartView.noDataText = "등록된 데이터가 없습니다"
        self.lineChartView.noDataFont = .systemFont(ofSize: 20)
        self.lineChartView.noDataTextColor = .lightGray
        
        self.lineChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: dateData)
        self.lineChartView.xAxis.setLabelCount(weightData.count, force: false)
        
        self.lineChartView.xAxis.drawAxisLineEnabled = true
        
        self.lineChartView.highlightPerTapEnabled = false // 좌표 표시선 비활성화
        
        self.lineChartView.scaleXEnabled = false // X축의 확대/축소 비활성화
        self.lineChartView.scaleYEnabled = false
        
        //self.lineChartView.xAxis.xOffset = 100.0
//        self.lineChartView.xAxis.yOffset = 10.0
        
        self.lineChartView.rightAxis.labelFont = .systemFont(ofSize: 0)
        
        self.lineChartView.leftAxis.spaceTop = 1
        self.lineChartView.leftAxis.axisLineWidth = 1
        self.lineChartView.xAxis.axisLineWidth = 1
        
        self.lineChartView.leftAxis.drawGridLinesEnabled = false
        
        self.lineChartView.xAxis.labelPosition = XAxis.LabelPosition.bottom
        
        self.lineChartView.legend.enabled = false
        
        self.lineChartView.extraBottomOffset = 10.0
        
        if weightData.count > 0 { // y축 위 아래로 여백, 축에 표시되는 범위
            self.lineChartView.leftAxis.axisMaximum = weightData.max()! + 10.0
            self.lineChartView.leftAxis.axisMinimum = weightData.min()! - 10.0
            //self.lineChartView.leftAxis.granularity = weightData.max()! + weightData.min()! / 2 * 5
             
            switch self.chartType {
            case "week":
                self.lineChartView.xAxis.spaceMin = Double(7 - weightData.count)
                break
            case "month":
                if weightData.count < 9 {
                    self.lineChartView.xAxis.spaceMin = Double(12 - weightData.count)
                    self.lineChartView.xAxis.labelCount = Int(floor(Double(weightData.count) / 1.2))
                } else if weightData.count < 16 {
                    self.lineChartView.xAxis.spaceMin = Double(20 - weightData.count)
                    self.lineChartView.xAxis.labelCount = Int(floor(Double(weightData.count) / 1.5))
                } else {
                    self.lineChartView.xAxis.spaceMin = Double(30 - weightData.count)
                    self.lineChartView.xAxis.labelCount = Int(floor(Double(weightData.count) / 2.0))
                }
                break
            case "year":
                if weightData.count < 7 {
                    self.lineChartView.xAxis.spaceMin = Double(8 - weightData.count)
                } else {
                    self.lineChartView.xAxis.spaceMin = Double(12 - weightData.count)
                }
                break
                
            default:
                self.lineChartView.xAxis.spaceMin = Double(7 - weightData.count)
                break
            }
            self.setLineData(lineChartView: self.lineChartView, lineChartDataEntries: self.entryData(values: self.weightData))
        }
        self.lineChartView.notifyDataSetChanged()
    }
    func setLineData(lineChartView: LineChartView, lineChartDataEntries:[ChartDataEntry]) {
        let lineChartDataSet = LineChartDataSet(entries: lineChartDataEntries)
        if lineChartDataEntries.isEmpty || lineChartView.data?.count == 0 {
            self.lineChartView.noDataText = "등록된 데이터가 없습니다"
            self.lineChartView.noDataFont = .systemFont(ofSize: 20)
            self.lineChartView.noDataTextColor = .lightGray // 데이터가 없을 때 표시할 텍스트 설정
        }
        // 라인 색상 지정
        lineChartDataSet.colors = [NSUIColor(cgColor: UIColor.mainColor!.cgColor)]
        lineChartDataSet.circleColors = [NSUIColor(cgColor: UIColor.mainColor!.cgColor)]
        lineChartDataSet.drawValuesEnabled = false
        lineChartDataSet.highlightEnabled = false
        
        //lineChartDataSet.
        
        let lineChartData = LineChartData(dataSet: lineChartDataSet)
        lineChartView.data = lineChartData
    }
    func entryData(values: [Double]) -> [ChartDataEntry] {
        var lineDataEntries: [ChartDataEntry] = []
        
        for i in 0 ..< values.count {
            let lineDataEntry = ChartDataEntry(x: Double(i), y: values[i])
            lineDataEntries.append(lineDataEntry)
        }
        //print("lineDataEntry : \(lineDataEntry)")
        print("lineDataEntries : \(lineDataEntries)")
        return lineDataEntries
    }
    
    // ==================
    // Dialog에서 Delegate
    func didUpdateData(_ viewController: WeightDialogViewController, updatedData: String) {
        if updatedData.lengthOfBytes(using: String.Encoding.utf8) > 0 {
            page = 1
            size = 20
            order = "default"
            isPaging = false // 현재 페이징 중인지 체크하는 flag
            hasNextPage = false // 마지막 페이지 인지 체크 하는 flag
            ListItem = []
            tableView.reloadData()
            petWeightListRequest(token: accessToken, page: page, size: size, order: order, idx: (petInfo?.idx)!)
            petWeightChartListRequest(token: accessToken, order: chartType, idx: (petInfo?.idx)!)
            DispatchQueue.main.async {
                self.customizeChart()
            }
        }
    }
    func updateCellLabel(with value: petWeightDetailItem, indexPath: IndexPath) {
        page = 1
        size = 20
        order = "default"
        isPaging = false // 현재 페이징 중인지 체크하는 flag
        hasNextPage = false // 마지막 페이지 인지 체크 하는 flag
        ListItem = []
        tableView.reloadData()
        petWeightListRequest(token: accessToken, page: page, size: size, order: order, idx: (petInfo?.idx)!)
        petWeightChartListRequest(token: accessToken, order: chartType, idx: (petInfo?.idx)!)
        DispatchQueue.main.async {
            self.customizeChart()
        }
    }
    // =======
    // api 요청
    // =======
    // 그래프 체중목록 불러오기
    // week, year의 경우 size는 20, month의 경우에는 30개로 설정
    func petWeightChartListRequest(token: String?, order: String, idx: Int) {
        self.dateData = []
        self.weightData = []
        let url = "https://api.reptimate.store/diaries/pet/\(idx)/weight?page=1&size=30&filter=\(order)&order=DESC"
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer "+token! , forHTTPHeaderField: "Authorization")
        // POST 로 보낼 정보
        if order == "year" {
            AF.request(url,
                    method: .get,
                    parameters: nil,
                    encoding: URLEncoding.default,
                       headers: ["Content-Type":"application/json", "Accept":"application/json", "Authorization":"Bearer "+token!])
                .responseDecodable(of: petWeightYearResponse.self) { response in
                switch response.result {
                case .success (let res):
                    
                    if response.value?.status == 200 {
                            DispatchQueue.main.async {
                                if let getItem = res.result {
                                    for i in stride(from: 0, to: getItem.count, by: 1) {
                                        self.dateData.append(String(getItem[i].month!))
                                        self.weightData.append(Double(getItem[i].average!))
                                    }
                                    if self.dateData.isEmpty {
                                        self.lineChartView.data = nil
                                    }
                                    self.customizeChart()
                                    print("=============================================")
                                    print("dateData : \(self.dateData)")
                                    print("weightData : \(self.weightData)")
                                    print("=============================================")
                                }
                            }
                    } else if response.value?.status == 401 || response.value?.statusCode == 401{
                       //acessToken 재발급, 실패시 acessToken은 유지
                        self.VCfunc.getAccessToken() {
                            let newAccessToken = UserDefaults.standard.string(forKey: "accessToken")
                            if newAccessToken != self.accessToken {
                               self.accessToken = UserDefaults.standard.string(forKey: "accessToken")!
                               // 새로 발급받은 acessToken(newAccessToken)으로 api재시도
                               self.petWeightChartListRequest(token: newAccessToken, order: order, idx: idx)
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
            }
        } else { // month, week 의 체중 그래프 데이터 조회
            AF.request(url,
                    method: .get,
                    parameters: nil,
                    encoding: URLEncoding.default,
                       headers: ["Content-Type":"application/json", "Accept":"application/json", "Authorization":"Bearer "+token!])
                .responseDecodable(of: SimpleResponse<petWeightResponse>.self) { response in
                switch response.result {
                case .success (let res):
                    if response.value?.status == 200 {
                        print("petWeightChartListRequest    ")
                        print(res)
                        let responseJson = try? JSONEncoder().encode(res.result)
                        let resultJson = try? JSONDecoder().decode(petWeightResponse.self, from: responseJson!)
                        
                            DispatchQueue.main.async {
                                if let getItem = resultJson?.items {
                                    for i in stride(from: 0, to: getItem.count, by: 1) {
                                        self.dateData.append(getItem[i].date!.clipDateString())
                                        self.weightData.append(Double(getItem[i].weight!))
                                    }
                                    if self.dateData == [] {
                                        self.lineChartView.data = nil
                                        self.lineChartView.notifyDataSetChanged()
                                    }
                                    self.customizeChart()
                                }
                            }
                    } else if response.value?.status == 401 || response.value?.statusCode == 401{
                       //acessToken 재발급, 실패시 acessToken은 유지
                        self.VCfunc.getAccessToken() {
                            let newAccessToken = UserDefaults.standard.string(forKey: "accessToken")
                            if newAccessToken != self.accessToken {
                               self.accessToken = UserDefaults.standard.string(forKey: "accessToken")!
                               // 새로 발급받은 acessToken(newAccessToken)으로 api재시도
                               self.petWeightChartListRequest(token: newAccessToken, order: order, idx: idx)
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
            }
        }
    }
    // 체중목록 불러오기
    func petWeightListRequest(token: String?, page: Int, size: Int, order: String, idx: Int) {
        LoadingService.showLoading()
        let url = "https://api.reptimate.store/diaries/pet/\(idx)/weight?page=\(page)&size=\(size)&filter=\(order)&order=DESC"
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
            .responseDecodable(of: SimpleResponse<petWeightResponse>.self) { response in
            switch response.result {
            case .success (let res):
                print("petWeightListRequest    ")
                print(res)
                if response.value?.status == 200 {
                    let responseJson = try? JSONEncoder().encode(res.result)
                    let resultJson = try? JSONDecoder().decode(petWeightResponse.self, from: responseJson!)
                    
                    let next = resultJson?.existsNextPage
                    self.hasNextPage = next!
                    
                    if self.hasNextPage == true {
                        self.page += 1
                    }
                    DispatchQueue.main.async {
                        if var getItem = resultJson?.items {
                            self.ListItem.append(contentsOf: getItem)
                            self.isPaging = false
                            self.tableView.reloadData()
                            self.tableViewHeight.constant = self.tableView.contentSize.height
                            if getItem.isEmpty {
                                
                            } else {
                                self.nowWeightLabel.text = String(getItem[0].weight ?? 0.0)
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
                           self.petWeightListRequest(token: newAccessToken, page: page, size: size, order: order, idx: idx)
                        } else {
                           self.VCfunc.showAlertAction1(vc: self, preferredStyle: .alert, title: "로그인 만료", message: "다시 로그인 해주시기 바랍니다.")
                           if let navigationController = self.navigationController {
                               navigationController.popToRootViewController(animated: true)
                           }
                        }
                    }
                   
                } else if response.value?.status == 409 {
                    
                } else if response.value?.status == 422 {
                    
                }
                break
            case .failure(let error):
                print("Request Error\nCode:\(error._code), Message: \(error.errorDescription!)")
            }
                LoadingService.hideLoading()
        }

    }
    // 체중 목록에서 삭제
    func deleteButtonTapped(at indexPath: IndexPath?) {
        if let indexPath = indexPath {
            var idx = ""
            if let a = ListItem[indexPath.row].idx {
                idx = "\(a)"
            }
            let url = "https://api.reptimate.store/diaries/weight/"+idx

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
                                self.VCfunc.showAlertAction1(vc: self, preferredStyle: .alert, title: "알림", message: "삭제 되었습니다.")
                                self.ListItem.remove(at: indexPath.row)
                                self.tableView.deleteRows(at: [indexPath], with: .automatic)
                                self.tableView.reloadData()
                                self.petWeightChartListRequest(token: self.accessToken, order: self.chartType, idx: (self.petInfo?.idx)!)
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
                                switch response.value?.errorCode {
                                case "CANNOT_FIND_PET":
                                    self.VCfunc.showAlertAction1(vc: self, preferredStyle: .alert, title: "알림", message: "등록한 반려동물 정보를 찾을 수 없습니다.")
                                    self.navigationController?.popViewController(animated: true)
                                case "CANNOT_FIND_WEIGHT":
                                    self.VCfunc.showAlertAction1(vc: self, preferredStyle: .alert, title: "알림", message: "등록한 체중 정보를 찾을 수 없습니다.")
                                    self.navigationController?.popViewController(animated: true)
                                case .none: break
                                case .some(_): break
                                }
                            } else if  response.value?.status == 409 {
                                self.VCfunc.showAlertAction1(vc: self, preferredStyle: .alert, title: "알림", message: "서버와의 통신에 오류가 발생하였습니다.")
                            } else {
                                print(response.value)
                                self.VCfunc.showAlertAction1(vc: self, preferredStyle: .alert, title: "알림", message: "서버와의 통신에 오류가 발생하였습니다.")
                            }
                            break
                        case .failure(let error):
                            print("체중 리스트 삭제 Request Error\nCode:\(error._code), Message: \(error.errorDescription!)")
                            self.VCfunc.showAlertAction1(vc: self, preferredStyle: .alert, title: "알림", message: "서버와의 통신에 오류가 발생하였습니다.")
                        }
                }
            }
    }
    
    
    @objc func weightDialog(sender: UITapGestureRecognizer){
        guard let WeightDialogViewController = self.storyboard?.instantiateViewController(withIdentifier: "WeightDialogViewController") as? WeightDialogViewController  else { return }
        // 뷰 컨트롤러가 보여지는 스타일
        WeightDialogViewController.modalPresentationStyle = .overCurrentContext
            // 뷰 컨트롤러가 사라지는 스타일)
        WeightDialogViewController.modalTransitionStyle = .crossDissolve
        
        WeightDialogViewController.delegate = self
        WeightDialogViewController.petInfo = self.petInfo
        self.present(WeightDialogViewController, animated: true, completion: nil)  // 생성
    }
    
    func setBtnInit() {
        self.chartWeeklyBtn.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        self.chartWeeklyBtn.layer.cornerRadius = 7
        self.chartWeeklyBtn.layer.borderColor = UIColor.mainColor?.cgColor
        self.chartWeeklyBtn.layer.borderWidth = 1
        self.chartWeeklyBtn.layer.masksToBounds = true
        
        
        self.chartMonthlyBtn.layer.borderColor = UIColor.lightGray.cgColor
        self.chartMonthlyBtn.layer.borderWidth = 1
        self.chartMonthlyBtn.layer.masksToBounds = true
        
        self.chartYearlyBtn.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        self.chartYearlyBtn.layer.cornerRadius = 7
        self.chartYearlyBtn.layer.borderColor = UIColor.lightGray.cgColor
        self.chartYearlyBtn.layer.borderWidth = 1
        self.chartYearlyBtn.layer.masksToBounds = true
        
        self.chartWeeklyBtn.setTitleColor(UIColor.mainColor, for: .selected)
        self.chartMonthlyBtn.setTitleColor(UIColor.mainColor, for: .selected)
        self.chartYearlyBtn.setTitleColor(UIColor.mainColor, for: .selected)
        
        self.chartWeeklyBtn.tintColor = UIColor.clear
        self.chartMonthlyBtn.tintColor = UIColor.clear
        self.chartYearlyBtn.tintColor = UIColor.clear
        
        self.chartWeeklyBtn.isSelected = true
        self.chartMonthlyBtn.isSelected = false
        self.chartYearlyBtn.isSelected = false
        
        
    }
}
extension Diary_PetWeightTabViewController: UITableViewDelegate, UITableViewDataSource {
    // Section을 2개 설정하는 이유는 페이징 로딩 시 로딩 셀을 표시
        func numberOfSections(in tableView: UITableView) -> Int {
            return 2
        }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let item = ListItem[indexPath.row]
//        guard let Diary_PetInfoViewController = self.storyboard?.instantiateViewController(withIdentifier: "Diary_PetInfoViewController") as? Diary_PetInfoViewController  else { return }
//        // 회원가입 완료시 토스트 메시지 위한 delegate
//
//        Diary_PetInfoViewController.Petinfo = item
//        self.navigationController?.pushViewController(Diary_PetInfoViewController, animated: true)
//        print(item)
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
            // 해당 indexPath에 높이값이 있다면 높이값을 반환하고 없으면 기본 값을 반환하도록 함
            return cellHeights[indexPath] ?? 70
        }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
            // 셀의 데이터 세팅이 완료 된 후 실제 높이 값을
            cellHeights[indexPath] = cell.frame.size.height
        }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if ListItem.count == 0 {
            self.tableView.setEmptyMessage("등록된 체중 기록이 없습니다.")
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
            guard let cell = tableView.dequeueReusableCell(withIdentifier: WeightTableViewCell.identifier, for: indexPath) as? WeightTableViewCell else { return UITableViewCell() }
            cell.delegate = self
            
            cell.setData(ListItem[indexPath.row])
            cell.petWeightDetailItem = ListItem[indexPath.row]
            //cell.token = self.accessToken
            
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: WeightLoadingTableViewCell.identifier, for: indexPath) as? WeightLoadingTableViewCell else { return UITableViewCell() }
                        
            cell.start()
                        
            return cell
        }
    }
}
