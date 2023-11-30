//
//  loadingCell.swift
//  ReptiMate
//
//  Created by 김기용 on 2023/05/04.
//

import UIKit

class loadingCell: UITableViewCell {
    
    static let identifier = "loadingCell"
    
    var delegate: loadingCellDelegate?
    
    @IBOutlet weak var activityIndicaterView: UIActivityIndicatorView!
    
    func start() {
        activityIndicaterView.startAnimating()
    }
}
protocol loadingCellDelegate {
    
    
}
