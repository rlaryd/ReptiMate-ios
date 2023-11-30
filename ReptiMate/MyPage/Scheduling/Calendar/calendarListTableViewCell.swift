//
//  calendarListTableViewCell.swift
//  ReptiMate
//
//  Created by 김기용 on 2023/06/19.
//

import UIKit

class calendarListTableViewCell: UITableViewCell {
    let VCfunc: VCfunc = .init()
    
    static let identifier = "calendarListTableViewCell"
    
    var delegate: calendarListTableViewCellDelegate?
    var indexPath: IndexPath?
 
    var scheduleInfo: CalendarStructs?
    var token: String?
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var moreBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func moreBtnClicked(_ sender: Any) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let editAction = UIAlertAction(title: "수정", style: .default) { (action) in
            if let vc = self.getViewController() {
                guard let editViewController = vc.storyboard?.instantiateViewController(withIdentifier: "makeCalendarViewController") as? makeCalendarViewController  else { return }
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
    
    func setData(_ scheduleInfo: CalendarStructs) {
        titleLabel.text = scheduleInfo.title
        timeLabel.text = scheduleInfo.alarmTime
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
protocol calendarListTableViewCellDelegate {
    
    func deleteButtonTapped(at indexPath: IndexPath?)
}
