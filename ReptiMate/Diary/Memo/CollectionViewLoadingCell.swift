//
//  CollectionViewLoadingCell.swift
//  ReptiMate
//
//  Created by 김기용 on 2023/05/11.
//

import UIKit

class CollectionViewLoadingCell: UICollectionViewCell {

    static let identifier = "CollectionViewLoadingCell"
    
    var delegate: CollectionViewLoadingCellDelegate?
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    
    func start() {
        activityIndicatorView.startAnimating()
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
protocol CollectionViewLoadingCellDelegate {
    
    
}
