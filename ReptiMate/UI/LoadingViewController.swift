//
//  LoadingViewController.swift
//  ReptiMate


import UIKit

class LoadingViewController: UIViewController {

    @IBOutlet weak var activityIndicaterView: UIActivityIndicatorView!
    
    static let identifier = "LoadingViewController"
    
    var LoadingViewControllerDelegate: LoadingViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    

    func start() {
        activityIndicaterView.startAnimating()
    }
    func finished() {
        activityIndicaterView.stopAnimating()
        self.dismiss(animated: false)
    }
    
}
protocol LoadingViewControllerDelegate {
    
    
}
