import UIKit

@IBDesignable class PaddingLabel: UILabel {

    @IBInspectable var topInset: CGFloat = 5.0
    @IBInspectable var bottomInset: CGFloat = 5.0
    @IBInspectable var leftInset: CGFloat = 8.0
    @IBInspectable var rightInset: CGFloat = 8.0
    
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets.init(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawText(in: rect.inset(by: insets))
    }

    override var intrinsicContentSize: CGSize {
    let size = super.intrinsicContentSize
    return CGSize(width: size.width + leftInset + rightInset, height: size.height + topInset + bottomInset)
    }
}



extension UITextField {
    // 텍스트필드 왼쪽에 여백
    func addLeftPadding() {
    let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: self.frame.height))
    self.leftView = paddingView
    self.leftViewMode = ViewMode.always
  }
}

extension UIView {
    
    // 요소에 테두리 넣기
    @IBInspectable var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
    @IBInspectable var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }
    @IBInspectable var borderColor: UIColor? {
        set {
            guard let uiColor = newValue else { return }
            layer.borderColor = uiColor.cgColor
        }
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
    }
    
}

extension UIViewController {
    
    // 키보드 내리기
    func hideKeyboardWhenTap() {
        let tap : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    func hideKeyboardWhenReturn(_ textField: UITextField) -> Bool{
        // 키보드 내리면서 동작
        textField.resignFirstResponder()
        return true
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // 스와이프 액션
    func swipeRecognizer() {
            // 오른쪽으로 스와이프시 뒤로가기
            let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture(_:)))
            swipeRight.direction = UISwipeGestureRecognizer.Direction.right
            self.view.addGestureRecognizer(swipeRight)
            
        }
        @objc func respondToSwipeGesture(_ gesture: UIGestureRecognizer){
            if let swipeGesture = gesture as? UISwipeGestureRecognizer {
                switch swipeGesture.direction{
                case UISwipeGestureRecognizer.Direction.right:
                    // 스와이프 시, 원하는 기능 구현.
                    // 네비게이션 컨트롤러상에서만 적용
                    self.navigationController?.popViewController(animated: true)
                    //self.dismiss(animated: true, completion: nil)
                default: break
                }
            }
        }
}
extension UICollectionView {
    // 1
    func setEmptyMessage(_ message: String) {
        let messageLabel: UILabel = {
            let label = UILabel()
            label.text = message
            label.textColor = .white
            label.numberOfLines = 0;
            label.textAlignment = .center;
            label.font = .boldSystemFont(ofSize: 15)
            label.sizeToFit()
            return label
        }()
        self.backgroundView = messageLabel;
    }
    // 2
    func restore() {
        self.backgroundView = nil
    }
}
extension UIColor {
    
    //  6D71E6
    class var mainColor: UIColor? { return UIColor(named: "mainColor") }
    //  A281E8
    class var subColor1: UIColor? { return UIColor(named: "subColor1") }
    //  A6C1F6
    class var subColor2: UIColor? { return UIColor(named: "subColor2") }
    
    
    class var genderMale: UIColor? { return UIColor(named: "genderBlue") }
    class var genderFemale: UIColor? { return UIColor(named: "genderFemale") }
    class var genderNone: UIColor? { return UIColor(named: "genderNone") }
    class var genderMaleSelected: UIColor? { return UIColor(named: "genderBlueSelected") }
    class var genderFemaleSelected: UIColor? { return UIColor(named: "genderFemaleSelected") }
    class var genderNoneSelected: UIColor? { return UIColor(named: "genderNoneSelected") }
}
