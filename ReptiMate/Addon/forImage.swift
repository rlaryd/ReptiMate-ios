
//  forImage.swift

import Foundation
import UIKit


extension UIImage {
     /// 이미지의 용량을 줄이기 위해서 리사이즈.
     /// - 가로, 세로 중 짧은 것이 720 보다 작다면 그대로 반환.
     /// - 가로, 세로 중 짧은 것이 720 보다 크다면 720 으로 리사이즈해서 반환.
     func resizeTo720() -> UIImage {
         let width = self.size.width
         let height = self.size.height
         let resizeLength: CGFloat = 720.0

         var scale: CGFloat

         if height >= width {
             scale = width <= resizeLength ? 1 : resizeLength / width
         } else {
             scale = height <= resizeLength ? 1 :resizeLength / height
         }

         let newHeight = height * scale
         let newWidth = width * scale
         let size = CGSize(width: newWidth, height: newHeight)
         let render = UIGraphicsImageRenderer(size: size)
         let renderImage = render.image { _ in
             self.draw(in: CGRect(origin: .zero, size: size))
         }
         return renderImage
     }
    
    static func getImageFromUrl(_ url: String, completion: @escaping (UIImage?) -> Void) {
            DispatchQueue.main.async {
                let cachedKey = NSString(string: url)

                if let cachedImage = ImageCacheManager.shared.object(forKey: cachedKey) {
                    completion(cachedImage)
                    return
                }

                guard let url = URL(string: url) else {
                    completion(nil)
                    return
                }

                URLSession.shared.dataTask(with: url) { (data, response, error) in
                    guard error == nil, let data = data, let image = UIImage(data: data) else {
                        completion(nil)
                        return
                    }

                    ImageCacheManager.shared.setObject(image, forKey: cachedKey)
                    completion(image)
                }.resume()
            }
        }
 }
class ImageCacheManager {
    static let shared = NSCache<NSString, UIImage>()
    private init() {}
}
extension UIImageView {
    func setImageUrl(_ url: String) {
        DispatchQueue.main.async {

            /// cache할 객체의 key값을 string으로 생성
            let cachedKey = NSString(string: url)

            /// cache된 이미지가 존재하면 그 이미지를 사용 (API 호출안하는 형태)
            if let cachedImage = ImageCacheManager.shared.object(forKey: cachedKey) {
                self.image = cachedImage
                return
            }
            guard let url = URL(string: url) else { return }
            URLSession.shared.dataTask(with: url) { (data, result, error) in
                guard error == nil else {
                    DispatchQueue.main.async { [weak self] in
                        self?.image = UIImage()
                    }
                    return
                }
                DispatchQueue.main.async { [weak self] in
                    if let data = data, let image = UIImage(data: data) {
                        /// 캐싱
                        ImageCacheManager.shared.setObject(image, forKey: cachedKey)
                        self?.image = image
                    }
                }
            }.resume()
        }
    }
}
