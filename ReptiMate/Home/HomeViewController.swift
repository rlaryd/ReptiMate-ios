
import UIKit


class HomeViewController: UIViewController {
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    
    // 이메일 정규식
    func isValidEmail(testStr: String?) -> Bool {
           
             let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
           
             let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
             return emailTest.evaluate(with: testStr)
              }
    
}

