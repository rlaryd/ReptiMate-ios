//
//  MemoWriteImgCollectionViewCell.swift
//  ReptiMate


import UIKit

class MemoWriteImgCollectionViewCell: UICollectionViewCell {
    
    var indexPathRow: Int?
    
    var getImg: UIImage?
    weak var delegate: MemoWriteImgCollectionViewCellDelegate?
    //static let identifier = "MemoWriteImgCollectionViewCell"
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var delBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

        
        override func layoutSubviews() {
            super.layoutSubviews()
        }
        
        override func prepareForReuse() {
            super.prepareForReuse()
        }
    
    
    @IBAction func delBtnClicked(_ sender: Any) {
        if let index = indexPathRow {
            delegate?.didDeselectButtonClicked(at: index)
        }
        
    }
    
    func setData(_ img: UIImage) {
        DispatchQueue.main.async {
            self.imageView.image = UIImage()
            self.imageView.image = img
        }
    }
    
    
    
    

}

protocol MemoWriteImgCollectionViewCellDelegate: AnyObject {
    
    func didDeselectButtonClicked(at indexPath: Int)
}
