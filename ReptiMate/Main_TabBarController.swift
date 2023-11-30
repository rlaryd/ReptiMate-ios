//
//  Main_TabBarController.swift
//  ReptiMate
//
//  Created by 김기용 on 2023/04/18.
//

import UIKit

class Main_TabBarController: UITabBarController {
    
    var fromNoti = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 메인 하단 탭 초기 화면 설정 0~n
        // 현재 마이페이지로 설정
        if (fromNoti == "auction") {
            self.selectedIndex = 0
        } else if (fromNoti == "chat") {
            if let communityViewController = viewControllers?[1] as? CommunityMainViewController {
                communityViewController.delegateData = "1" // 원하는 데이터 전달
            }
            self.selectedIndex = 1
        } else {
            self.selectedIndex = 3
        }
        
    }
}
