//
//  WeightLoadingTableViewCell.swift
//  ReptiMate
//
//  Created by 김기용 on 2023/05/30.
//

import UIKit

class WeightLoadingTableViewCell: UITableViewCell {

    static let identifier = "WeightLoadingTableViewCell"
    var delegate: WeightLoadingTableViewCellDelegate?
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    func start() {
        activityIndicatorView.startAnimating()
    }

}
protocol WeightLoadingTableViewCellDelegate {
    
    
}
