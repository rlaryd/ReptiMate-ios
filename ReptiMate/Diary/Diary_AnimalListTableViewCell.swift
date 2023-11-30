//
//  Diary_AnimalListTableViewCell.swift
//  ReptiMate
//
//  Created by 김기용 on 2023/05/01.
//
import Foundation
import UIKit
import Then
import Alamofire




class Diary_AnimalListTableViewCell: UITableViewCell {
    let VCfunc: VCfunc = .init()
    
    static let identifier = "Diary_AnimalListTableViewCell"
    
    var delegate: Diary_AnimalListTableViewCellDelegate?
    var indexPath: IndexPath?
 
    var petinfo: petListItem?
    var token: String?

    
    @IBOutlet weak var AnimalImageView: UIImageView!
    @IBOutlet weak var AnimalNameLabel: UILabel!
    @IBOutlet weak var AnimalTypeLabel: UILabel!
    @IBOutlet weak var AnimalGenderLabel: PaddingLabel!
    
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
                guard let editViewController = vc.storyboard?.instantiateViewController(withIdentifier: "Diary_EditAnimalViewController") as? Diary_EditAnimalViewController  else { return }
                
                editViewController.petInfo = self.petinfo
                
                
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

    
    
    func setData(_ petListItem: petListItem) {
        petinfo = petListItem
        if ((petListItem.imagePath) != nil) {
            // 이미지 경로 URL 생성
            let imageURL = URL(string: (petListItem.imagePath)!)
            
            self.AnimalImageView.setImageUrl(petListItem.imagePath!)
            self.AnimalImageView.borderColor = .clear
            self.AnimalImageView.cornerRadius = 10
            self.AnimalImageView.clipsToBounds = true
            self.AnimalImageView.translatesAutoresizingMaskIntoConstraints = false
            

        } else {
            DispatchQueue.main.async {
                self.AnimalImageView.image = UIImage(named: "png+3+(1)")
            }
            
        }
        AnimalNameLabel.text = petListItem.name
        AnimalTypeLabel.text = petListItem.type
        
        if petListItem.gender == "MALE" {
            AnimalGenderLabel.text = "수컷"
            AnimalGenderLabel.textColor = .white
            AnimalGenderLabel.backgroundColor = .genderMale
            AnimalGenderLabel.borderColor = .clear
            AnimalGenderLabel.cornerRadius = 8
            AnimalGenderLabel.clipsToBounds = true
        } else if petListItem.gender == "FEMALE" {
            AnimalGenderLabel.text = "암컷"
            AnimalGenderLabel.textColor = .white
            AnimalGenderLabel.backgroundColor = .genderFemale
            AnimalGenderLabel.borderColor = .clear
            AnimalGenderLabel.cornerRadius = 8
            AnimalGenderLabel.clipsToBounds = true
        } else {
            AnimalGenderLabel.text = "미구분"
            AnimalGenderLabel.textColor = .white
            AnimalGenderLabel.backgroundColor = .genderNone
            AnimalGenderLabel.borderColor = .clear
            AnimalGenderLabel.cornerRadius = 8
            AnimalGenderLabel.clipsToBounds = true
        }
        
    }
    
    // =======
    // api 요청
    // =======

    // 회원정보 수정
    func DeleteAnimalRequest(idx: String, token: String?) {
        
        
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
protocol Diary_AnimalListTableViewCellDelegate {
    
    func deleteButtonTapped(at indexPath: IndexPath?)
}


    


