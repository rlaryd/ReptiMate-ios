//
//  MemoDetailCollectionViewCell.swift
//  ReptiMate
//
//  Created by 김기용 on 2023/05/11.
//

import UIKit

class MemoDetailCollectionViewCell: UICollectionViewCell {
    
    var indexPath: IndexPath?
    var petMemoDetail: petMemoDetailImgItem?
    var imgList: [UIImage] = []
    var img: UIImage?
    var getImg: String?
    @IBOutlet weak var imageView: UIImageView!
    
    static let identifier = "MemoDetailCollectionViewCell"
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    
    
    func setData(_ img: UIImage) {
        DispatchQueue.main.async {
            self.imageView.image = img
            self.imageView.clipsToBounds = true
            self.imageView.translatesAutoresizingMaskIntoConstraints = false
            
//            if ((img.deletedAt?.isEmpty) != nil) {
//
//            } else {
//                let a = img
//                self.imageView.setImageUrl(a.imagePath!)
//                self.imageView.clipsToBounds = true
//                self.imageView.translatesAutoresizingMaskIntoConstraints = false
//            }
            
        }
    }
}
