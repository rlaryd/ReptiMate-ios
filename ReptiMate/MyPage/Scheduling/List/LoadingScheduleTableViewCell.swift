//
//  LoadingScheduleTableViewCell.swift
//  ReptiMate
//
//  Created by 김기용 on 2023/06/14.
//

import UIKit

class LoadingScheduleTableViewCell: UITableViewCell {
    
    static let identifier = "LoadingScheduleTableViewCell"
    var delegate: LoadingScheduleTableViewCellDelegate?

    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    func start() {
        activityIndicatorView.startAnimating()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

protocol LoadingScheduleTableViewCellDelegate {
    
    
}
