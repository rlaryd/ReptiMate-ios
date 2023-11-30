//
//  MemoListCollectionViewCell.swift
//  ReptiMate
//
//  Created by 김기용 on 2023/05/08.
//

import UIKit

class MemoListCollectionViewCell: UICollectionViewCell {
    
    var indexPath: IndexPath?
 
    var memoInfo: petMemoItem?
    
    static let identifier = "MemoListCollectionViewCell"
    
    var imageViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var MemoTitleLabel: UILabel!
    @IBOutlet weak var MemoDateLabel: UILabel!
    @IBOutlet weak var MemoYearLabel: UILabel!
    
    @IBOutlet weak var MemoImageView: UIImageView!
    
    //var petMemoItem: petMemoItem
    
    override func awakeFromNib() {
        super.awakeFromNib()
            
    }
    

        
        
        
    func setData(_ petMemoItem: petMemoItem) {
        memoInfo = petMemoItem
        
        if let a = petMemoItem.imagePath {
            self.MemoImageView.image = UIImage()
            self.MemoImageView.setImageUrl(a)
            self.MemoImageView.borderColor = .clear
            self.MemoImageView.cornerRadius = 10
            self.MemoImageView.clipsToBounds = true
            self.MemoImageView.translatesAutoresizingMaskIntoConstraints = false
        }
        
        
            
            
        MemoTitleLabel.text = petMemoItem.title
        
        var memoWritten = petMemoItem.createdAt
        let memoYear = memoWritten?.substring(from: 0, to: 3)
        let memoMonth = memoWritten?.substring(from: 5, to: 6)
        let memoDay = memoWritten?.substring(from: 8, to: 9)
        
        MemoYearLabel.text = String(describing: memoYear!)
        MemoDateLabel.text = "\(String(describing: memoMonth!))/\(String(describing: memoDay!))"
        
        
        
    }
    
}
