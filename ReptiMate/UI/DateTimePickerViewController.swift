//
//  DatePickerViewController.swift
//  ReptiMate
//
//  Created by 김기용 on 2023/05/02.
//

import UIKit

final class DateTimePickerViewController: UIViewController, UIGestureRecognizerDelegate {
    @IBOutlet weak var datePicker: UIDatePicker!

    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var backView: UIView!
    
    weak var delegate: DateTimePickerVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.clear
        
    }
    @IBAction func saveBtnClicked(_ sender: Any) {
        // datePicker의 format 형식을 정의해줍니다.
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        
        dateFormatter.string(from: self.datePicker.date)
        self.dismiss(animated: false)
    }
    
    func initUI() {
        let tapGesture = UITapGestureRecognizer()
        tapGesture.delegate = self
        self.backView.addGestureRecognizer(tapGesture)
        setDatePicker()
    }

    func setDatePicker() {
        if #available(iOS 14.0, *) {
            datePicker.preferredDatePickerStyle = .inline
        } else {
            datePicker.preferredDatePickerStyle = .automatic
        }
        // locale 설정을 해주고
        datePicker.locale = Locale(identifier: "ko_KR")
        datePicker.calendar.locale = Locale(identifier: "ko_KR")

        // 현재 시간에 맞게 자동으로 업데이트 하게 해주고
        datePicker.timeZone = .autoupdatingCurrent

        // 피커에 달력과 시간을 설정하는 것 두개를 다 사용할 것입니다.
        datePicker.datePickerMode = .dateAndTime
        datePicker.sizeToFit()

        // 피커의 데이터를 선택했을 때 어떤 동작을 하게 할지 addTarget도 추가해볼 수 있습니다.
        datePicker.addTarget(self, action: #selector(handleDatePicker(_:)), for: .valueChanged)

        // 선택된 날짜, 주된 컬러를 설정
        datePicker.tintColor = .mainColor
        
        // 오늘로부터 과거 날짜 블러처리
        datePicker.minimumDate = Date()
    }

    // 피커의 데이터를 선택했을 때 어떤 행위를 할지 정의해주는 함수
    @objc func handleDatePicker(_ sender: UIDatePicker) {
        print(sender.date)
    }
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive event: UIEvent) -> Bool {
        self.dismiss(animated: false)
        return true
    }
    

}
protocol DateTimePickerVCDelegate: AnyObject {
    func updateDateTime(_ dateTime: String)
}
