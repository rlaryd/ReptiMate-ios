//
//  cycleSelectViewController.swift
//  ReptiMate
//
//  Created by 김기용 on 2023/06/14.
//

import UIKit

protocol cycleSelectViewControllerDelegate {
    func dataSend(data: String)
}

class cycleSelectViewController: UIViewController {
    let VCfunc: VCfunc = .init()
    
    var delegate: cycleSelectViewControllerDelegate?
    var radioArray = [0,0,0,0,0,0,0]
    var radioString: String = ""
    var isEdit: Bool = false
    
    
    @IBOutlet weak var sunRadioBtn: UIButton!
    @IBOutlet weak var monRadioBtn: UIButton!
    @IBOutlet weak var tueRadioBtn: UIButton!
    @IBOutlet weak var wedRadioBtn: UIButton!
    @IBOutlet weak var thuRadioBtn: UIButton!
    @IBOutlet weak var friRadioBtn: UIButton!
    @IBOutlet weak var satRadioBtn: UIButton!
    
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initBtn()
        self.hideKeyboardWhenTap()
        self.swipeRecognizer()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isEdit {
            print("==")
            print("=========makePlanViewController 에서 delegate  :  \(radioArray)")
            print("==")
            presetBtn()
        }
    }
    func presetBtn() {
        
        
        if radioArray[0] == 1 {
            sunRadioBtn.isSelected = true
        }
        if radioArray[1] == 1 {
            monRadioBtn.isSelected = true
        }
        if radioArray[2] == 1 {
            tueRadioBtn.isSelected = true
        }
        if radioArray[3] == 1 {
            wedRadioBtn.isSelected = true
        }
        if radioArray[4] == 1 {
            thuRadioBtn.isSelected = true
        }
        if radioArray[5] == 1 {
            friRadioBtn.isSelected = true
        }
        if radioArray[6] == 1 {
            satRadioBtn.isSelected = true
        }
        
    }
    func initBtn() {
        sunRadioBtn.setImage(UIImage(named: "uncheck")?.withTintColor(.mainColor!), for: .normal)
        sunRadioBtn.setImage(UIImage(named: "check")?.withTintColor(.mainColor!), for: .selected)
        monRadioBtn.setImage(UIImage(named: "uncheck")?.withTintColor(.mainColor!), for: .normal)
        monRadioBtn.setImage(UIImage(named: "check")?.withTintColor(.mainColor!), for: .selected)
        
        tueRadioBtn.setImage(UIImage(named: "uncheck")?.withTintColor(.mainColor!), for: .normal)
        tueRadioBtn.setImage(UIImage(named: "check")?.withTintColor(.mainColor!), for: .selected)
        
        wedRadioBtn.setImage(UIImage(named: "uncheck")?.withTintColor(.mainColor!), for: .normal)
        wedRadioBtn.setImage(UIImage(named: "check")?.withTintColor(.mainColor!), for: .selected)
        thuRadioBtn.setImage(UIImage(named: "uncheck")?.withTintColor(.mainColor!), for: .normal)
        thuRadioBtn.setImage(UIImage(named: "check")?.withTintColor(.mainColor!), for: .selected)
        friRadioBtn.setImage(UIImage(named: "uncheck")?.withTintColor(.mainColor!), for: .normal)
        friRadioBtn.setImage(UIImage(named: "check")?.withTintColor(.mainColor!), for: .selected)
        satRadioBtn.setImage(UIImage(named: "uncheck")?.withTintColor(.mainColor!), for: .normal)
        satRadioBtn.setImage(UIImage(named: "check")?.withTintColor(.mainColor!), for: .selected)
    }
    @IBAction func radioClick(_ sender: UIButton) {
        if sender == sunRadioBtn {
            if sunRadioBtn.isSelected {
                sunRadioBtn.isSelected = false
                radioArray[0] = 0
            } else {
                sunRadioBtn.isSelected = true
                radioArray[0] = 1
            }
        } else if sender == monRadioBtn {
            if monRadioBtn.isSelected {
                monRadioBtn.isSelected = false
                radioArray[1] = 0
            } else {
                monRadioBtn.isSelected = true
                radioArray[1] = 1
            }
        } else if sender == tueRadioBtn {
            if tueRadioBtn.isSelected {
                tueRadioBtn.isSelected = false
                radioArray[2] = 0
            } else {
                tueRadioBtn.isSelected = true
                radioArray[2] = 1
            }
        } else if sender == wedRadioBtn {
            if wedRadioBtn.isSelected {
                wedRadioBtn.isSelected = false
                radioArray[3] = 0
            } else {
                wedRadioBtn.isSelected = true
                radioArray[3] = 1
            }
        } else if sender == thuRadioBtn {
            if thuRadioBtn.isSelected {
                thuRadioBtn.isSelected = false
                radioArray[4] = 0
            } else {
                thuRadioBtn.isSelected = true
                radioArray[4] = 1
            }
        } else if sender == friRadioBtn {
            if friRadioBtn.isSelected {
                friRadioBtn.isSelected = false
                radioArray[5] = 0
            } else {
                friRadioBtn.isSelected = true
                radioArray[5] = 1
            }
        } else if sender == satRadioBtn {
            if satRadioBtn.isSelected {
                satRadioBtn.isSelected = false
                radioArray[6] = 0
            } else {
                satRadioBtn.isSelected = true
                radioArray[6] = 1
            }
        }
    }
    func arrayToString() {
        for i in stride(from: 0, to: radioArray.count, by: 1) {
            radioString = radioString + String(radioArray[i])
            if i < radioArray.count - 1 {
                radioString = radioString + ","
            }
        }
    }
    @IBAction func backBtnPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func applyBtnPressed(_ sender: Any) {
        arrayToString()
        self.delegate?.dataSend(data: self.radioString)
        print("==========")
        print("====applyBtnPressed : [\(self.radioString)]======")
        print("==========")
        self.navigationController?.popViewController(animated: true)
    }
    
}



