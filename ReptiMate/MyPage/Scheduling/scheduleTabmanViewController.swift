//
//  scheduleTabmanViewController.swift
//  ReptiMate
//
//  Created by 김기용 on 2023/06/13.
//

import UIKit
import Tabman
import Pageboy

import Alamofire



class scheduleTabmanViewController: TabmanViewController {
    
    var viewHeight: CGFloat?
    
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var tempView: UIView!
    @IBOutlet weak var containerView: UIView!
    
    private var viewControllers: [UIViewController] = []
    let weightVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "calendarListViewController") as! calendarListViewController
    let diaryVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "planListViewController") as! planListViewController
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.swipeRecognizer()
        viewHeight = containerView.frame.height
        diaryVC.topHeight = self.viewHeight
        weightVC.topHeight = self.viewHeight
        
        
        setTabman()
        viewControllers.append(weightVC)
        viewControllers.append(diaryVC)
        self.dataSource = self
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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

}
extension scheduleTabmanViewController: PageboyViewControllerDataSource, TMBarDataSource {
    
    func barItem(for bar: TMBar, at index: Int) -> TMBarItemable {
        switch index {
        case 0:
            return TMBarItem(title: "달력")
        case 1:
            return TMBarItem(title: "반복")
        
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
