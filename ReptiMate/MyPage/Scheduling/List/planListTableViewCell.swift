//
//  planListTableViewCell.swift

import UIKit

class planListTableViewCell: UITableViewCell {
    let VCfunc: VCfunc = .init()
    
    static let identifier = "planListTableViewCell"
    
    var delegate: planListTableViewCellDelegate?
    var indexPath: IndexPath?
 
    var scheduleInfo: ScheduleStructs?
    var token: String?
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var repeatLabel: UILabel!
    
    @IBOutlet weak var moreBtn: UIButton!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    @IBAction func moreBtnClicked(_ sender: Any) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let editAction = UIAlertAction(title: "수정", style: .default) { (action) in
            if let vc = self.getViewController() {
                guard let editViewController = vc.storyboard?.instantiateViewController(withIdentifier: "makePlanViewController") as? makePlanViewController  else { return }
                
                editViewController.scheduleInfo = self.scheduleInfo
                editViewController.isEdit = true
                
                vc.navigationController?.pushViewController(editViewController, animated: true)
            }
        }
        alertController.addAction(editAction)
        
        let deleteAction = UIAlertAction(title: "삭제", style: .destructive) { (action) in
            // TODO: Delete row
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
    func setData(_ scheduleInfo: ScheduleStructs) {
        titleLabel.text = scheduleInfo.title
        timeLabel.text = scheduleInfo.alarmTime
        if let repeatDaySet = getRepeatDayString(scheduleInfo.repeatDay!) as? String {
            repeatLabel.text = repeatDaySet
            //print("===========setData : \(getRepeatDayString(scheduleInfo.repeatDay!))=================")
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
                        self.delegate?.deleteButtonTapped(at: indexPath)
                    }
                }
                alert.addAction(cancelAction)
                alert.addAction(completeAction)
                currentVc.present(alert, animated: true, completion: nil)
            }
        }
}
protocol planListTableViewCellDelegate {
    
    func deleteButtonTapped(at indexPath: IndexPath?)
}
