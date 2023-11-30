////
////  UploadWKSchemeHandler.swift
////  ReptiMate
////
////  Created by 김기용 on 2023/11/02.
////
//
//import Foundation
//import WebKit
//import Photos
//import RxSwift
//
//class UploadWKSchemeHandler: NSObject, WKURLSchemeHandler {
//    private var imageMime = "image/jpeg"
//    private var textMime = "text/plain"
//    private var disposeBag = DisposeBag()
//
//    func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
//        guard let url = urlSchemeTask.request.url else  { return }
//        guard let queryItem = URLComponents(url: url, resolvingAgainstBaseURL: true)?.queryItems?.first else { return }
//        guard let value = queryItem.value else { return }
//
//        if queryItem.name == PreviewViewModel.imageQueryName {
//            makeImageResponse(url: url, identifier: value, urlSchemeTask: urlSchemeTask)
//        }
//
//        if queryItem.name == PreviewViewModel.textQueryName {
//            makeTextResponse(url: url, text: value, urlSchemeTask: urlSchemeTask)
//        }
//    }
//
//    func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {
//
//    }
//
//    private func makeImageResponse(url: URL, identifier: String, urlSchemeTask: WKURLSchemeTask) {
//        requestImage(identifier: identifier)
//        .subscribe(onNext: { [unowned self] content in
//            let urlResponse = URLResponse(url: url, mimeType: self.imageMime, expectedContentLength: -1, textEncodingName: nil)
//            urlSchemeTask.didReceive(urlResponse)
//            urlSchemeTask.didReceive(content.data)
//            urlSchemeTask.didFinish()
//        }).disposed(by: disposeBag)
//    }
//
//    private func makeTextResponse(url: URL, text: String, urlSchemeTask: WKURLSchemeTask) {
//        let urlResponse = URLResponse(url: url, mimeType: textMime, expectedContentLength: -1, textEncodingName: nil)
//        urlSchemeTask.didReceive(urlResponse)
//        urlSchemeTask.didFinish()
//    }
//
//    private func requestImage(identifier: String) -> Observable<DataImage> {
//        let imageManager = PHImageManager.default()
//        let option = PHImageRequestOptions()
//        option.isNetworkAccessAllowed = true
//        option.deliveryMode = .highQualityFormat
//
//        guard let asset = PHAsset.fetchAssets(withLocalIdentifiers: [identifier], options: nil).firstObject else { return .never()}
//
//        return Observable<DataImage>.create({ observe in
//            imageManager
//                .requestImageData(for: asset,
//                                  options: option,
//                                  resultHandler: { data, dataFormat, _, info in
//                    guard let data = data else { return observe.onError(UploadViewModel.error.noData) }
//                    guard let format = dataFormat else { return observe.onError(UploadViewModel.error.noData) }
//                    if format.hasSuffix("gif") {
//                        observe.onNext(DataImage(type: .animatedImage ,data: data, fileName: "public.gif"))
//                        observe.onCompleted()
//
//                    } else if let pngData = UIImage(data: data)?.fixedOrientation()?.pngData() {
//                        observe.onNext(DataImage(type: .staticImage, data: pngData, fileName: "public.png"))
//                        observe.onCompleted()
//
//                    } else {
//                        observe.onError(UploadViewModel.error.cantLoadImageFromAlbum)
//                    }
//                })
//            return Disposables.create()
//        })
//    }
//}
