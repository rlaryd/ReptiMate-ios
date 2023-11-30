//
//  memoImgDetailCollectionViewCell.swift
//  ReptiMate
//
//  Created by 김기용 on 2023/07/04.
//

import UIKit
// 메모 이미지 상세보기 cell
class memoImgDetailCollectionViewCell: UICollectionViewCell, UIScrollViewDelegate {
    //var indexPath: IndexPath?
    //var petMemoDetail: petMemoDetailImgItem?
    var imgList: [UIImage] = []
    var imgItem: UIImage?
    var getImg: String?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    static let identifier = "memoImgDetailCollectionViewCell"
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        scrollView.delegate = self
        
        let doubleTap = UITapGestureRecognizer(target:self,action:#selector(self.doubleTap(gesture:)))
        doubleTap.numberOfTapsRequired = 2
        self.imageView.isUserInteractionEnabled = true
        self.imageView.addGestureRecognizer(doubleTap)
        self.scrollView.maximumZoomScale = 4.0
        self.scrollView.minimumZoomScale = 1.0
    }

    
    func setData(_ img: UIImage) {
        
        
        DispatchQueue.main.async {
            let a = img
            self.imageView.image = a
            self.imageView.clipsToBounds = true
            self.imageView.translatesAutoresizingMaskIntoConstraints = false
            
            
        }
    }
    
    @objc func doubleTap(gesture: UITapGestureRecognizer){
            if ( self.scrollView.zoomScale < self.scrollView.maximumZoomScale ) {
            //if ( self.scrollView.zoomScale < 3 ) {
                let newScale:CGFloat = self.scrollView.zoomScale * 3
                let zoomRect:CGRect = self.zoomRectForScale(scale: newScale, center: gesture.location(in: gesture.view))
                self.scrollView.zoom(to: zoomRect, animated: true)
                
            } else {
                self.scrollView.setZoomScale(1.0, animated: true)
            }
    }
    
    func zoomRectForScale(scale:CGFloat, center: CGPoint) -> CGRect{
            var zoomRect: CGRect = CGRect()
            zoomRect.size.height = self.scrollView.frame.size.height / scale
            zoomRect.size.width = self.scrollView.frame.size.width / scale
            
            zoomRect.origin.x = center.x - zoomRect.size.width / 2.0
            zoomRect.origin.y = center.y - zoomRect.size.height / 2.0
            
            return zoomRect
    }
    
    // UIScrollViewDelegate
        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return imageView
        }
    
    
}
