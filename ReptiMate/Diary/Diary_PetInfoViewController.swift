//  Diary_PetInfoViewController.swift
//  ReptiMate


import UIKit
import Tabman
import Pageboy

import Alamofire

class Diary_PetInfoViewController: TabmanViewController {
    
    var Petinfo: petListItem?
    var viewHeight: CGFloat?
    
    @IBOutlet weak var backBtn: UIButton!
    
    @IBOutlet weak var AnimalProfileImageView: UIImageView!

    @IBOutlet weak var AnimalGenderLabel: UILabel!

    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var AnimalNameLabel: UILabel!
    @IBOutlet weak var AnimalTypeLabel: UILabel!
    @IBOutlet weak var AnimalBirthDateLabel: UILabel!

    @IBOutlet weak var AnimalAdoptDateLabel: UILabel!
    
    @IBOutlet weak var AnimalBirthDateStackView: UIStackView!
    @IBOutlet weak var AnimalAdoptDateStackView: UIStackView!
    
    var BirthDateheight: NSLayoutConstraint!
    var AdoptDateheight: NSLayoutConstraint!
    var birthDateWidth: NSLayoutConstraint!
    
    private var viewControllers: [UIViewController] = []

    let weightVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Diary_PetWeightTabViewController") as! Diary_PetWeightTabViewController
    let diaryVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Diary_PetMemoTabViewController") as! Diary_PetMemoTabViewController

    @IBOutlet weak var tempView: UIView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.swipeRecognizer()
        
        viewHeight = infoView.frame.height
        
        BirthDateheight = AnimalBirthDateStackView.heightAnchor.constraint(equalToConstant: 0)
        AdoptDateheight = AnimalAdoptDateLabel.heightAnchor.constraint(equalToConstant: 0)
        birthDateWidth = AnimalBirthDateStackView.widthAnchor.constraint(equalToConstant: 0)
        BirthDateheight.isActive = true
        AdoptDateheight.isActive = true
        
        viewControllers.append(weightVC)
        viewControllers.append(diaryVC)

        setData(Petinfo!)
        
        self.dataSource = self
                
        setTabman()
        
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    private func setTabman() {
        let bar = TMBar.ButtonBar()
                
        //탭바 레이아웃 설정
        bar.layout.transitionStyle = .snap
        bar.layout.alignment = .centerDistributed
        //bar.layout.contentMode = .fit
        bar.layout.contentMode = .intrinsic
        //        .fit : indicator가 버튼크기로 설정됨
        bar.layout.interButtonSpacing = view.bounds.width / 4

        //배경색
        bar.backgroundView.style = .clear
        bar.backgroundColor = .clear
                
        //간격설정
        bar.layout.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 20)
                
        //버튼 글시 커스텀
        bar.buttons.customize{
            (button) in
            button.tintColor = .black
            button.selectedTintColor = .mainColor
            button.font = UIFont.systemFont(ofSize: 15)
        }
        //indicator
        bar.indicator.weight = .custom(value: 2)
        bar.indicator.tintColor = .mainColor
        //bar.indicator.overscrollBehavior = .bounce
        bar.indicator.overscrollBehavior = .compress
        
        addBar(bar, dataSource: self, at:.custom(view: tempView, layout: nil))
    }

    // =========
    // 뷰 처리
    // =========
    func setData(_ petListItem: petListItem) {
        diaryVC.petInfo = petListItem
        weightVC.petInfo = petListItem
        diaryVC.topHeight = self.viewHeight
        weightVC.topHeight = self.viewHeight
        
        
        if let imgPath = petListItem.imagePath {
            let pathLength = imgPath.count
            print("pathLength  :  \(pathLength)")
            if pathLength > 3 {
                // 이미지 경로 URL 생성
                let imageURL = URL(string: imgPath)

                // URL을 통해 이미지 다운로드
                if let url = imageURL {
                    DispatchQueue.global(qos: .userInitiated).async {
                        if let imageData = try? Data(contentsOf: url) {
                            DispatchQueue.main.async {
                                // 이미지 다운로드가 완료된 후 UI 업데이트
                                let image = UIImage(data: imageData)
                                self.AnimalProfileImageView.image = image
                                self.AnimalProfileImageView.borderColor = .clear
                                self.AnimalProfileImageView.cornerRadius = 20
                                self.AnimalProfileImageView.clipsToBounds = true
                                
                                self.AnimalProfileImageView.translatesAutoresizingMaskIntoConstraints = false
                            }
                        }
                    }
                }
            }
           
        } else {
            DispatchQueue.main.async {
                self.AnimalProfileImageView.image = UIImage(named: "png+3+(1)")
                self.AnimalProfileImageView.borderColor = .clear
                self.AnimalProfileImageView.cornerRadius = 20
                self.AnimalProfileImageView.clipsToBounds = true
            }
        }
        AnimalNameLabel.text = petListItem.name
        AnimalTypeLabel.text = petListItem.type
        
        var birth = petListItem.birthDate?.split(separator: "T")
        var adopt = petListItem.adoptionDate?.split(separator: "T")
        
        
        if (petListItem.birthDate?.count ?? 0) > 1 {
            BirthDateheight.isActive = false
            AnimalBirthDateLabel.text = String(birth![0])
        } else {
            BirthDateheight.isActive = true
            birthDateWidth.isActive = true
        }
        if (petListItem.adoptionDate?.count ?? 0) > 1 {
            AdoptDateheight.isActive = false
            AnimalAdoptDateLabel.text = String(adopt![0])
        } else {
            AdoptDateheight.isActive = true
        }
        
        if petListItem.gender == "MALE" {
            AnimalGenderLabel.text = "수컷"
            AnimalGenderLabel.backgroundColor = .genderMale
            AnimalGenderLabel.borderColor = .clear
            AnimalGenderLabel.cornerRadius = 8
            AnimalGenderLabel.clipsToBounds = true
            
        } else if petListItem.gender == "FEMALE" {
            AnimalGenderLabel.text = "암컷"
            AnimalGenderLabel.backgroundColor = .genderFemale
            AnimalGenderLabel.borderColor = .clear
            AnimalGenderLabel.cornerRadius = 8
            AnimalGenderLabel.clipsToBounds = true
            
        } else {
            AnimalGenderLabel.text = "미구분"
            AnimalGenderLabel.backgroundColor = .genderNone
            AnimalGenderLabel.borderColor = .clear
            AnimalGenderLabel.cornerRadius = 8
            AnimalGenderLabel.clipsToBounds = true
        }
        
        
        
    }
    
    

}
extension Diary_PetInfoViewController: PageboyViewControllerDataSource, TMBarDataSource {
    
    func barItem(for bar: TMBar, at index: Int) -> TMBarItemable {
        switch index {
        case 0:
            return TMBarItem(title: "체중")
        case 1:
            return TMBarItem(title: "메모")
        
        default:
            let title = "Page \(index)"
           return TMBarItem(title: title)
        }
    }

    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
        return viewControllers.count
    }
    
    func viewController(for pageboyViewController: PageboyViewController, at index: PageboyViewController.PageIndex) -> UIViewController? {
        return viewControllers[index]
    }
    
    func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
        return nil
    }
}

