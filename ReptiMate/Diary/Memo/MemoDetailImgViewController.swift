//
//  MemoDetailImgViewController.swift
//

import UIKit

// 메모 이미지 상세보기 VC
class MemoDetailImgViewController: UIViewController {
    
    var imgList: [UIImage] = []
    
    var firstIdx: Int?
    var totalCnt: Int?
    
    @IBOutlet weak var backBtn: UIButton!
    
    @IBOutlet weak var nowNumber: UILabel!
    @IBOutlet weak var totalImgCount: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.delegate = self
        collectionView?.dataSource = self
        
        if let a = firstIdx {
            nowNumber.text = String(a + 1)
            collectionView.scrollToItem(at: IndexPath(row: a, section: 0), at: .right, animated: false)
        }
        if let b = totalCnt {
            totalImgCount.text = String(b)
        }
        
        

    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }


}
extension MemoDetailImgViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let width = scrollView.bounds.size.width
        // 좌표보정을 위해 절반의 너비를 더해줌
        let x = scrollView.contentOffset.x + (width/2)
        
        let newPage = Int(x / width) + 1
        if Int(nowNumber.text!) != newPage {
            nowNumber.text = String(newPage)
        }
    }
    
    // CollectionView item 개수
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imgList.count
    }
    
    // CollectionView Cell의 Object
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "memoImgDetailCollectionViewCell", for: indexPath) as! memoImgDetailCollectionViewCell
        
        cell.setData(imgList[indexPath.row])
        
        
        return cell
    }
    
    // CollectionView Cell의 Size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return collectionView.frame.size
        
    }
    
    // CollectionView Cell의 위아래 간격
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return 1.0
//    }
    
//    // CollectionView Cell의 옆 간격
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        return 1.0
//    }
    
    // 셀이 선택되었을 때
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        
    }
    
    // 셀이 넘어갔을 때
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
            if let itemCell = cell as? memoImgDetailCollectionViewCell {
                itemCell.scrollView.setZoomScale(1.0, animated: true)
            }
    }
    
    
    
    
    
    
}
