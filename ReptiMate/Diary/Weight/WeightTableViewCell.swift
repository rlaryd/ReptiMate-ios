//
//  WeightTableViewCell.swift
//  ReptiMate
//
//  Created by 김기용 on 2023/05/17.
//

import UIKit

class WeightTableViewCell: UITableViewCell {
    let VCfunc: VCfunc = .init()
    
    static let identifier = "WeightTableViewCell"
    
    var delegate: WeightTableViewCellDelegate?
    weak var delegate2: WeightDialogViewControllerDelegate?
    var indexPath: IndexPath?
 
    var petWeightDetailItem: petWeightDetailItem?
    var token: String?
    
     
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var changeLabel: UILabel!
    
    @IBOutlet weak var changeUnit: UILabel!
    @IBOutlet weak var deleteBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//    }
    

    
    @IBAction func moreBtnSelected(_ sender: Any) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let editAction = UIAlertAction(title: "수정", style: .default) { (action) in
            if let vc = self.getViewController() {
                
                guard let WeightDialogViewController = vc.storyboard?.instantiateViewController(withIdentifier: "WeightDialogViewController") as? WeightDialogViewController  else { return }
                // 뷰 컨트롤러가 보여지는 스타일
                WeightDialogViewController.modalPresentationStyle = .overCurrentContext
                // 뷰 컨트롤러가 사라지는 스타일
                WeightDialogViewController.modalTransitionStyle = .crossDissolve

                WeightDialogViewController.petWeightDetailItem = self.petWeightDetailItem
                WeightDialogViewController.isEdit = true
                WeightDialogViewController.isEdits = "YES"
                if let tableView = self.superview as? UITableView,
                    let indexPath = tableView.indexPath(for: self) {
                    WeightDialogViewController.indexPath = indexPath
                }

                WeightDialogViewController.delegate2 = self

                //WeightDialogViewController.delegate = self.window?.rootViewController as? DataUpdateDelegate

                //vc.present(WeightDialogViewController, animated: true, completion: nil)  // 생성
                self.window?.rootViewController?.present(WeightDialogViewController, animated: true, completion: nil)  // 생성
                //vc.navigationController?.pushViewController(WeightDialogViewController, animated: true)
                

                //self.showDialog()
            }
            
        }
        alertController.addAction(editAction)
        
        let deleteAction = UIAlertAction(title: "삭제", style: .destructive) { (action) in
            self.showAlertAction(vc: self.getViewController(), preferredStyle: .alert, title: "알림", message: "정말 삭제 하시겠습니까?")
        }
        alertController.addAction(deleteAction)
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel) { (action) in
            // TODO: Do nothing
        }
        alertController.addAction(cancelAction)
        
        if let vc = getViewController() {
            vc.present(alertController, animated: true, completion: nil)
        }
    }
    
    func setData(_ petWeightDetailItem: petWeightDetailItem) {
        
        var petWeightItem = petWeightDetailItem
        
        weightLabel.text = String(format: "%.1f", petWeightItem.weight!)
        
        let fullDate = petWeightDetailItem.date!
        let Year = fullDate.substring(from: 2, to: 3)
        let Month = fullDate.substring(from: 5, to: 6)
        let Day = fullDate.substring(from: 8, to: 9)
        
        dateLabel.text = "\(String(describing: Year)).\(String(describing: Month)).\(String(describing: Day))"
        
        changeLabel.text = String(format: "%.1f", petWeightItem.weightChange!)
        
        if let a = petWeightItem.weightChange {
            if a < 0.0 {
                changeLabel.textColor = UIColor.blue
                changeUnit.textColor = UIColor.blue
            } else if a > 0.0 {
                changeLabel.textColor = UIColor.red
                changeUnit.textColor = UIColor.red
                
            }
        }
        
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
//        dateFormatter.timeZone = TimeZone(abbreviation: "UTC") // 문자열의 시간대를 설정합니다. "Z"는 UTC 시간을 의미합니다.
//
//        if let date = dateFormatter.date(from: fullDate) {
//            // 날짜 변환 성공
//            let calendar = Calendar.current
//            let updatedDate = calendar.date(byAdding: .hour, value: 9, to: date)
//            print(updatedDate)
//            let updatedDateString = dateFormatter.string(from: updatedDate ?? Date())
//            let Year = updatedDateString.substring(from: 2, to: 3)
//            let Month = updatedDateString.substring(from: 5, to: 6)
//            let Day = updatedDateString.substring(from: 8, to: 9)
//
//            dateLabel.text = "\(String(describing: Year)).\(String(describing: Month)).\(String(describing: Day))"
//        } else {
//            // 날짜 변환 실패
//            print("Invalid date string")
//        }
        
        
    }
    
    
    private func getViewController() -> UIViewController? {
        var responder: UIResponder? = self
        while responder != nil {
            if let viewController = responder as? UIViewController {
                return viewController
            }
            responder = responder?.next
        }
        return nil
    }
    func showAlertAction(vc: UIViewController? = UIApplication.shared.keyWindow?.visibleViewController, preferredStyle: UIAlertController.Style = .alert, title: String = "", message: String = "", cancelTitle: String = "취소", completeTitle: String = "삭제",  _ cancelHandler: (() -> Void)? = nil, _ completeHandler: (() -> Void)? = nil){
            
            guard let currentVc = vc else {
                completeHandler?()
                return
            }
            
            DispatchQueue.main.async {
                let alert = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
                
                let cancelAction = UIAlertAction(title: cancelTitle, style: .cancel) { action in
                    cancelHandler?()
                }
                let completeAction = UIAlertAction(title: completeTitle, style: .default) { action in
                    completeHandler?()
                    if let tableView = self.superview as? UITableView,
                        let indexPath = tableView.indexPath(for: self) {
                        // TODO: Delete row from tableView's data source
                        
                        
                        self.delegate?.deleteButtonTapped(at: indexPath)
                    }
                }
                
                alert.addAction(cancelAction)
                alert.addAction(completeAction)
                
                currentVc.present(alert, animated: true, completion: nil)
            }
        }
    
}
protocol WeightTableViewCellDelegate {
    func deleteButtonTapped(at indexPath: IndexPath?)
    //func weightEdited(at indexPath: IndexPath?, updatedData: petWeightDetailItem)
}


    
extension WeightTableViewCell: WeightDialogViewControllerDelegate {
    func didFinishEditingCell(updatedData: petWeightDetailItem, indexPath: IndexPath) {
        // 현재의 뷰 컨트롤러를 찾음
        var viewController = self.next
        while viewController != nil && !(viewController is UIViewController) {
            viewController = viewController?.next
        }
            
        // 현재의 뷰 컨트롤러가 UIViewController 1일 경우에만 처리
        if let viewController1 = viewController as? Diary_PetWeightTabViewController {
            // 셀의 레이블을 갱신
            viewController1.updateCellLabel(with: updatedData, indexPath: indexPath)
        }
    }
    
    
}


    
