//
//  StreamerViewController.swift
//  ReptiMate
//
//  Created by 김기용 on 2023/07/05.
//

import UIKit
import LFLiveKit
import Alamofire
import AVFoundation
import WebKit
//import AVFoundation

class StreamerViewController: UIViewController, WKScriptMessageHandler {

    let VCfunc: VCfunc = .init()
    
    var session: LFLiveSession!
    var audioSession = AVAudioSession.sharedInstance()
    
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var mikeBtn: UIButton!
    @IBOutlet weak var switchCameraBtn: UIButton!
    @IBOutlet weak var moreBtn: UIButton!
    @IBOutlet weak var onAirStatusBtn: UIButton!
    @IBOutlet weak var exitBtn: UIButton!
    
    @IBOutlet weak var watchLimitDownBtn: UIButton!
    @IBOutlet weak var watchLimitUpBtn: UIButton!
    
    @IBOutlet weak var playTimeLabel: UILabel!
    @IBOutlet weak var viewerLabel: UILabel!
    @IBOutlet weak var infoTitleLabel: UILabel!
    @IBOutlet weak var bidAmountLabel: UILabel!
    
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var exitView: UIView!
    @IBOutlet weak var menuStackView: UIStackView!
    
    @IBOutlet weak var infoImageView: UIImageView!
    
    @IBOutlet weak var moreMenu: UIMenu!
    
    @IBOutlet weak var modalView: UIView!
    
    @IBOutlet weak var watchLimitStackView: UIStackView!
    
    @IBOutlet weak var watchLimitLabel: UILabel!
    
    @IBOutlet weak var resolutionBtn: UIButton!
    @IBOutlet weak var frameBtn: UIButton!
    
    @IBOutlet weak var WatchLimitModalView: UIView!
    @IBOutlet weak var watchLimitModal: UIView!
    
    @IBOutlet weak var watchLimitTextField: UITextField!
    
    var infoViewheight: NSLayoutConstraint!
    var exitBtnheight: NSLayoutConstraint!
    
    @IBOutlet weak var modalConstraint: NSLayoutConstraint!
    @IBOutlet weak var watchModalConstrait: NSLayoutConstraint!
    
    var refreshToken = ""
    var accessToken = ""
    var idx = ""
    var nickname = ""
    var profilePath = ""
    
    var receivedData = ""
    var streamKey = "8BLW-GGgj-yH3n-76PN-KRF0"
    var boardIdx = ""
    
    var timer: Timer?
    var seconds = 0
    
    var finished = false
    var mikeIsOn = true
    
    var tapGesture: UITapGestureRecognizer!
    
    var audioConfiguration = LFLiveAudioConfiguration.default()
    var videoConfiguration = LFLiveVideoConfiguration.defaultConfiguration(for: LFLiveVideoQuality.sHigh1, outputImageOrientation: .landscapeRight)
    var videoQuality = LFLiveVideoQuality.sHigh1
    var streamResolution = "1080p"
    var streamFrame = "30fps"
    var streamSettingEdited = false
    
    @IBOutlet weak var streamInfoView: UIView!
    private var webView: WKWebView!
    var infoUrl = "https://web.reptimate.store/"
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "streamManagerViewController" {
            if let destinationVC = segue.destination as? streamManagerViewController {
                // 데이터 전달
                destinationVC.boardIdx = sender as! String
            }
        }
    }
    //MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        hideswipeRecognizer()
        
        if let Token = UserDefaults.standard.string(forKey: "accessToken") {
            accessToken = Token
        } else {
            //navigationController?.popViewController(animated: true)
        }
        
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
        } catch {
            print("Failed to set AVAudioSession category: \(error.localizedDescription)")
        }
        NotificationCenter.default.addObserver(self, selector: #selector(updateTimerLabel), name: Notification.Name("TimerUpdated"), object: nil)
        exitBtnheight = exitView.heightAnchor.constraint(equalToConstant: 0)
        
        UIinit()
        
        self.view.backgroundColor = .white
        let screenW = UIScreen.main.bounds.size.width
        
        //MARK: 시작/종료버튼
        playBtn.addTarget(self, action: #selector(playBtnOnClick(btn:)), for: .touchUpInside)
        
        //MARK: 카메라 전환 버튼
        switchCameraBtn.addTarget(self, action: #selector(switchCameraBtnOnClick(btn:)), for: .touchUpInside)
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(openWatchLimit(_:)))
        watchLimitStackView.addGestureRecognizer(tapGesture)
        
        //설정값
        let audioConfiguration = LFLiveAudioConfiguration.default()
        let videoConfiguration = LFLiveVideoConfiguration.defaultConfiguration(for: LFLiveVideoQuality.sHigh1, outputImageOrientation: .landscapeRight)
        
        //MARK: 세션 초기화
        session = LFLiveSession(audioConfiguration: audioConfiguration, videoConfiguration: videoConfiguration)
        session.delegate = self
        
        session.preView = self.view

        session.captureDevicePosition = .back
     
        self.requestAccessForAudio()
        self.requestAccessForVideo()
//
//        auctionInfoRequest(boardIdx: boardIdx)
//        infoWebViewInit()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if (session != nil) {
            session.stopLive()
        }
        TimerManager.shared.stopTimer()
    }
    func infoWebViewInit(){
//        accessToken = UserDefaults.standard.string(forKey: "accessToken")!
//        refreshToken = UserDefaults.standard.string(forKey: "refreshToken")!
//        idx = UserDefaults.standard.string(forKey: "idx")!
//        nickname = UserDefaults.standard.string(forKey: "nickname")!
//        profilePath = UserDefaults.standard.string(forKey: "profilePath")!
                
        do {
            if let cookie = try HTTPCookie(properties: [
                .domain: "web.reptimate.store",
                .path: "/",
                .name: "myAppCookie",
                .value: "{\"accessToken\" : \"\(accessToken)\",\"refreshToken\" : \"\(refreshToken)\",\"idx\" : \"\(idx)\",\"profilePath\" : \"\(profilePath)\",\"nickname\" : \"\(nickname)\"}",
                .secure: true,
            ]) {
                var setUrl = self.infoUrl+"streamhosttop/"+boardIdx
                // 쿠키 생성 성공한 경우
                let preferences = WKWebpagePreferences()
                preferences.allowsContentJavaScript = true
                
                let userContentController = WKUserContentController()
                userContentController.add(self, name: "consoleLogHandler")
                let configuration = WKWebViewConfiguration()
                configuration.userContentController = userContentController
                configuration.defaultWebpagePreferences = preferences
                
                let uctionWebView = WKWebView(frame: self.streamInfoView.bounds, configuration: configuration)
                uctionWebView.scrollView.bounces = true
                uctionWebView.navigationDelegate = self
                uctionWebView.uiDelegate = self
                uctionWebView.autoresizingMask = [.flexibleWidth, . flexibleHeight]
                uctionWebView.scrollView.showsVerticalScrollIndicator = false
                uctionWebView.scrollView.showsHorizontalScrollIndicator = false
                uctionWebView.allowsBackForwardNavigationGestures = true
                
                uctionWebView.scrollView.minimumZoomScale = 1.0
                uctionWebView.scrollView.maximumZoomScale = 1.0
                
                uctionWebView.scrollView.minimumZoomScale = 1.0
                uctionWebView.scrollView.maximumZoomScale = 1.0
                
                
                uctionWebView.configuration.websiteDataStore.httpCookieStore.setCookie(cookie) {
                   // 쿠키 등록 완료 후 처리
                    self.streamInfoView.addSubview(uctionWebView)
                    var urlString = ""

                    if let url = URL(string: setUrl) {
                        let request = URLRequest(url: url)
                        uctionWebView.load(request)
                        print("===========urlString : streamInfoView : ")
                        print(setUrl)
                        print("===============================")
                    }
                }
            } else {
                print("쿠키 생성 실패")
            }
        } catch let error {
            print("쿠키 생성 중 오류 발생: \(error)")
        }

    }
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "consoleLogHandler", let logMessage = message.body as? String {
            print("JavaScript 콘솔 출력: \(logMessage)")
        }
    }
    func auctionInfoRequest(boardIdx: String!) {
        LoadingService.showLoading()

        let url = "https://api.reptimate.store/board/"+boardIdx
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // POST 로 보낼 정보
        AF.request(url,
                method: .get,
                parameters: nil,
                encoding: URLEncoding.default,
                   headers: ["Content-Type":"application/json", "Accept":"application/json"])
            .responseDecodable(of: AuctionInfoResponse.self) { response in
            switch response.result {
            case .success (let res):
                if response.value?.status == 200 {
                    let responseJson = try? JSONEncoder().encode(res.result)
                    let resultJson = try? JSONDecoder().decode(AuctionInfo.self, from: responseJson!)

                    print("================================")
                    print("auctionInfoRequest  :  \(resultJson)")
                    print("================================")
                    if ((resultJson?.images) != nil) {
                        // 이미지 경로 URL 생성
                        if resultJson?.images?[0].category == "img" {
                            let imageURL = URL(string: (resultJson?.images?[0].path)!)
                            // URL을 통해 이미지 다운로드
                            if let url = imageURL {
                                DispatchQueue.global(qos: .userInitiated).async {
                                    if let imageData = try? Data(contentsOf: url) {
                                        DispatchQueue.main.async {
                                            // 이미지 다운로드가 완료된 후 UI 업데이트
                                            let image = UIImage(data: imageData)
                                            self.infoImageView.image = image
                                        }
                                    }
                                }
                            }
                        } else {
                            let imageURL = URL(string: (resultJson?.images?[0].coverImgPath)!)
                            // URL을 통해 이미지 다운로드
                            if let url = imageURL {
                                DispatchQueue.global(qos: .userInitiated).async {
                                    if let imageData = try? Data(contentsOf: url) {
                                        DispatchQueue.main.async {
                                            // 이미지 다운로드가 완료된 후 UI 업데이트
                                            let image = UIImage(data: imageData)
                                            self.infoImageView.image = image
                                        }
                                    }
                                }
                            }
                        }
                        
                    }
                    self.infoTitleLabel.text = resultJson?.title
                
                } else if response.value?.status == 404 {
                    if let navigationController = self.navigationController {
                        navigationController.popToRootViewController(animated: true)
                    }
                } else if response.value?.status == 422 {
                    
                } else {
                    self.VCfunc.showAlertAction1(vc: self, preferredStyle: .alert, title: "알림", message: "\(response.value?.status) : 서버와의 통신에 오류가 발생하였습니다.")
                }
                LoadingService.hideLoading()
                break
            case .failure(let error):
                print("Request Error\nCode:\(error._code), Message: \(error.errorDescription!)")
                self.VCfunc.showToast(message: "서버와의 통신에 오류가 발생하였습니다.", wid: 180)
            }
        }

    }

    func UIinit() {
        
        setStreamResolutionMenu()
        setStreamFrameMenu()
        
        let manager = UIAction(title: "방송 관리자", handler: { _ in
            print("방송 관리자")
//            if let streamManagerViewController = self.storyboard?.instantiateViewController(withIdentifier: "streamManagerViewController") as? streamManagerViewController {
//                // 데이터 할당
//                streamManagerViewController.boardIdx = self.boardIdx
//                self.navigationController?.pushViewController(streamManagerViewController, animated: true)
//            }
            self.performSegue(withIdentifier: "streamManagerViewController", sender: self.boardIdx)
        })
        let setting = UIAction(title: "방송 설정", handler: { _ in
            print("방송 설정")
            self.modalConstraint.constant = 0
            UIView.animate(withDuration: 0.3, animations: {self.view.layoutIfNeeded()})
        })
        
        let buttonMenu = UIMenu(children: [setting, manager])
        
        moreBtn.menu = buttonMenu
        
        playBtn.titleLabel?.text = ""
        exitBtn.titleLabel?.text = ""
        mikeBtn.titleLabel?.text = ""
        switchCameraBtn.titleLabel?.text = ""
        
        playBtn.layer.cornerRadius = playBtn.frame.height/2
        playBtn.layer.borderWidth = 1
        playBtn.layer.borderColor = UIColor.clear.cgColor
        playBtn.clipsToBounds = true
        
        exitView.layer.cornerRadius = exitView.frame.height/2
        exitView.layer.borderWidth = 1
        exitView.layer.borderColor = UIColor.clear.cgColor
        exitView.clipsToBounds = true
        
        playBtn.setImage(UIImage(named: "ic_pause"), for: .selected)
        
        onAirStatusBtn.setTitle("오프라인", for: .normal)
        onAirStatusBtn.setTitle("방송중", for: .selected)
        onAirStatusBtn.setBackgroundColor(.white, for: .normal)
        onAirStatusBtn.setBackgroundColor(.red, for: .selected)
        onAirStatusBtn.setTitleColor(.black, for: .normal)
        onAirStatusBtn.setTitleColor(.white, for: .selected)
        onAirStatusBtn.layer.cornerRadius = 7
        onAirStatusBtn.layer.borderWidth = 1
        onAirStatusBtn.layer.borderColor = UIColor.white.cgColor
        onAirStatusBtn.clipsToBounds = true
        
        menuStackView.layoutMargins = UIEdgeInsets(top: .zero, left: 15, bottom: .zero, right: 15)
        menuStackView.isLayoutMarginsRelativeArrangement = true
        
        modalView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        modalView.layer.cornerRadius = 7
        modalView.layer.borderColor = UIColor.clear.cgColor
        modalView.layer.borderWidth = 1
        modalView.layer.masksToBounds = true
        
        watchLimitUpBtn.setTitle("", for: .normal)
        watchLimitDownBtn.setTitle("", for: .normal)
        
        watchLimitModal.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        watchLimitModal.layer.cornerRadius = 7
        watchLimitModal.layer.borderColor = UIColor.clear.cgColor
        watchLimitModal.layer.borderWidth = 1
        watchLimitModal.layer.masksToBounds = true
        
        
    }
    
    //MARK: 방송 관리자 설정
    func setStreamResolutionMenu() {
        let res1080p = UIAction(title: "1080p", handler: { _ in
            self.resolutionBtn.setTitle("1080p", for: .normal)
            self.streamResolution = "1080p"
            self.streamSettingEdited = true
        })
        let res720p = UIAction(title: "720p", handler: { _ in
            self.resolutionBtn.setTitle("720p", for: .normal)
            self.streamResolution = "720p"
            self.streamSettingEdited = true
        })
        let res540p = UIAction(title: "540p", handler: { _ in
            self.resolutionBtn.setTitle("540p", for: .normal)
            self.streamResolution = "540p"
            self.streamSettingEdited = true
        })
        let res360p = UIAction(title: "360p", handler: { _ in
            self.resolutionBtn.setTitle("360p", for: .normal)
            self.streamResolution = "360p"
            self.streamSettingEdited = true
        })
        let resolutionBtnMenu = UIMenu(children: [res360p, res540p, res720p, res1080p])
        resolutionBtn.menu = resolutionBtnMenu
    }
    func setStreamFrameMenu() {
        let fps30 = UIAction(title: "30fps", handler: { _ in
            self.frameBtn.setTitle("30fps", for: .normal)
            self.streamFrame = "30fps"
            self.streamSettingEdited = true
        })
        let fps60 = UIAction(title: "60fps", handler: { _ in
            self.frameBtn.setTitle("60fps", for: .normal)
            self.streamFrame = "60fps"
            self.streamSettingEdited = true
        })
        let frameBtnMenu = UIMenu(children: [fps30, fps60])
        frameBtn.menu = frameBtnMenu
    }
    func editVideoQuality() {
        switch (self.streamResolution, self.streamFrame) {
        case ("1080p", "30fps"):
            videoQuality = LFLiveVideoQuality.sHigh1
        case ("1080p", "60fps"):
            videoQuality = LFLiveVideoQuality.sHigh1
        case ("720p", "30fps"):
            videoQuality = LFLiveVideoQuality.high1
        case ("720p", "60fps"):
            videoQuality = LFLiveVideoQuality.high2
        case ("540p", "30fps"):
            videoQuality = LFLiveVideoQuality.medium2
        case ("540p", "60fps"):
            videoQuality = LFLiveVideoQuality.medium3
        case ("360p", "30fps"):
            videoQuality = LFLiveVideoQuality.low2
        case ("360p", "60fps"):
            videoQuality = LFLiveVideoQuality.low3
        case (_, _):
            videoQuality = LFLiveVideoQuality.sHigh1
        }
    }
    // 방송관리자 모달 내리기
    func hideswipeRecognizer() {
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondTohideSwipeGesture(_:)))
        swipeRight.direction = UISwipeGestureRecognizer.Direction.down
        self.view.addGestureRecognizer(swipeRight)
        }
        @objc func respondTohideSwipeGesture(_ gesture: UIGestureRecognizer){
            if let swipeGesture = gesture as? UISwipeGestureRecognizer {
                switch swipeGesture.direction {
                case UISwipeGestureRecognizer.Direction.down:
                    self.modalConstraint.constant = -215
                    if streamSettingEdited {
                        print("=====================================")
                        print("스트리밍 설정 변경됨")
                        print("=====================================")
                        self.editVideoQuality()
                        self.session.stopLive()
                        self.restartSession(LFLiveVideoQuality: self.videoQuality)
                    }
                    self.streamSettingEdited = false
                    UIView.animate(withDuration: 0.3, animations: {self.view.layoutIfNeeded()})
                default: break
                }
            }
        }

    
    //MARK: - 버튼 Event
    @objc func playBtnOnClick(btn: UIButton) {
        btn.isSelected = !btn.isSelected
        
        if btn.isSelected {
            btn.backgroundColor = .red
            self.onAirStatusBtn.isSelected = true
            self.onAirStatusBtn.layer.borderColor = UIColor.red.cgColor
            self.onAirStatusBtn.clipsToBounds = true
            self.exitView.isHidden = true
            self.exitBtn.isEnabled = false
            self.exitBtnheight.isActive = true
            print(":::: 시작 버튼 클릭됨 :::: ")
            //TimerManager.shared.startTimer()
            self.finished = false
            startLive()
            
            self.resolutionBtn.isEnabled = false
            self.frameBtn.isEnabled = false
            tapGesture.isEnabled = false
        } else {
            btn.backgroundColor = .white
            self.onAirStatusBtn.isSelected = false
            self.onAirStatusBtn.layer.borderColor = UIColor.white.cgColor
            self.onAirStatusBtn.clipsToBounds = true
            self.exitView.isHidden = false
            self.exitBtn.isEnabled = true
            self.exitBtnheight.isActive = false
            print(":::: 종료 버튼 해제됨 :::: ")
            //TimerManager.shared.stopTimer()
            self.finished = true
            stopLive()
            
            self.resolutionBtn.isEnabled = true
            self.frameBtn.isEnabled = true
            tapGesture.isEnabled = true
        }
    }
    
    @IBAction func exitBtnPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    //MARK: 최대 인원 설정 모달
    @objc func openWatchLimit(_ sender: UITapGestureRecognizer) {
        self.watchModalConstrait.constant = 0
    }
    @IBAction func closeWatchLimit(_ sender: Any) {
        self.watchModalConstrait.constant = -1200
        self.watchLimitTextField.text = self.watchLimitLabel.text
    }
    @IBAction func setWatchLimit(_ sender: Any) {
        self.watchLimitLabel.text = self.watchLimitTextField.text
        self.watchModalConstrait.constant = -1200
    }
    @IBAction func watchLimitUp(_ sender: Any) {
        if let text = self.watchLimitTextField.text, let watchLimit = Int(text) {
            if watchLimit < 100 {
                self.watchLimitTextField.text = String(watchLimit + 1)
            }
        } else {
            print("Invalid input")
        }
    }
    @IBAction func watchLimitDown(_ sender: Any) {
        if let text = self.watchLimitTextField.text, let watchLimit = Int(text) {
            if watchLimit > 1 {
                self.watchLimitTextField.text = String(watchLimit - 1)
            }
        } else {
            print("Invalid input")
        }
    }
    
    
    //MARK: 화면전환 버튼
    @objc func switchCameraBtnOnClick(btn: UIButton) {
        if session.captureDevicePosition == .back {
            session.captureDevicePosition = .front
        }else if session.captureDevicePosition == .front {
            session.captureDevicePosition = .back
        }
    }
    //MARK: 마이크 음소거
    @IBAction func mikeControlOnClick(_ sender: Any) {
        if mikeIsOn {
            do {
                try audioSession.setActive(false)
            } catch {
                print("Failed to deactivate AVAudioSession: \(error.localizedDescription)")
            }
        } else {
            do {
                try audioSession.setActive(true)
                try audioSession.overrideOutputAudioPort(.speaker)
            } catch {
                print("Failed to activate AVAudioSession: \(error.localizedDescription)")
            }
        }
        mikeIsOn = !mikeIsOn
    }
    
    
    
    //MARK: 스트리밍 관련
    func startLive() -> Void {
        if (streamKey.count > 0) {
            print(":::: 라이브 시작 :::: ")
            let stream = LFLiveStreamInfo()
            //stream.url = "rtmp://나의 도메인/live/test"             //hls 방식으로 스트리밍 요청
            //stream.url = "rtmp://43.201.165.228/live/kiyong"; //src"     //rtmp 방식으로 스트리밍 요청
//            stream.url = "rtmp://live.reptimate.store/live/"+streamKey
            stream.url = "rtmp://live.reptimate.store/live/8BLW-GGgj-yH3n-76PN-KRF0"
            session.startLive(stream)
            TimerManager.shared.startTimer()
        }
    }
    func stopLive() -> Void {
        print(":::: 라이브 정지 :::: ")
        //session.running = false
        session.stopLive()
        TimerManager.shared.stopTimer()
        //updateTimerLabel()
        
        restartSession(LFLiveVideoQuality: self.videoQuality)
    }
    func restartSession(LFLiveVideoQuality: LFLiveVideoQuality) {
        print("세션 재시작")
        let audioConfiguration = LFLiveAudioConfiguration.default()
        let videoConfiguration = LFLiveVideoConfiguration.defaultConfiguration(for: LFLiveVideoQuality, outputImageOrientation: .landscapeRight)
        session = LFLiveSession(audioConfiguration: audioConfiguration, videoConfiguration: videoConfiguration)
        session.delegate = self
        session.preView = self.view
        
        session.captureDevicePosition = .back
        DispatchQueue.main.async {
            self.session.running = true
        }
    }
    
    
    //MARK: 비디오 접근
    func requestAccessForVideo()  {
        print(":::: 비디오 접근권한 체크 :::: ")

        let state = AVCaptureDevice.authorizationStatus(for: .video)

        switch state {
        case .notDetermined:
            print(":::: 비디오 접근 notDetermined :::: ")
            
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (grandted) in
                guard grandted else { return }
                DispatchQueue.main.async {
                    self.session.running = true
                }
            })
        case.authorized:
            print(":::: 이미 비디오 접근 승인 얻었음 :::: ")
            DispatchQueue.main.async {
                self.session.running = true
            }
            break
        case.denied:
            print(":::: 비디오 접근 denied :::: ")
            break
        case.restricted:
            print(":::: 비디오 접근 restricted :::: ")
            break
            
        @unknown default:
            print("....")
        }
        
    }
    
    //MARK: 오디오 접근
    func requestAccessForAudio()  {
        print(":::: 오디오 접근권한 체크 :::: ")

        let state = AVCaptureDevice.authorizationStatus(for:.audio)
        switch state {
        case .notDetermined:
            print(":::: 오디오 접근 notDetermined :::: ")
            AVCaptureDevice.requestAccess(for: .audio, completionHandler: { (granted) in
                guard granted else{
                    return
                }
            })
        case.authorized:
            print(":::: 이미 오디오 접근 승인 얻었음 :::: ")
            break
            
        case.denied:
            print(":::: 오디오 접근 denied :::: ")
            break
            
        case.restricted:
            print(":::: 오디오 접근 restricted :::: ")
            break
            
        @unknown default:
            print("....")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopLive()
        session.running = false
    }
    
    @objc private func updateTimerLabel() {
        let currentTime = TimerManager.shared.getCurrentTime()
        let timeString = timeFormatted(currentTime)
        playTimeLabel.text = timeString
    }
        
    private func timeFormatted(_ totalSeconds: Int) -> String {
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = (totalSeconds % 3600) % 60
            
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    
}

//MARK: LFLiveSessionDelegate
extension StreamerViewController : LFLiveSessionDelegate {
    //MARK: - Callback
    func liveSession(_ session: LFLiveSession?, debugInfo: LFLiveDebug?){
        print(":::: debugInfo: \(String(describing: debugInfo?.currentBandwidth))")    }
    
    func liveSession(_ session: LFLiveSession?, errorCode: LFLiveSocketErrorCode){
        print(":::: errorCode : \(errorCode.rawValue)")
    }
    
    func liveSession(_ session: LFLiveSession?, liveStateDidChange state: LFLiveState){
        print(":::: liveStateDidChange: \(state.rawValue)")
        switch state {
        case .ready:
            print("준비")
        case .pending:
            print("연결중...")
        case .start:
            print("실시간 스트리밍 시작")
        case .refresh:
            print("리프레쉬...")
        case .stop:
            print("정지")
        case .error:
            print("오류...")
        @unknown default:
            print(".....")
        }
    }
    

}
extension StreamerViewController: WKNavigationDelegate {
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
    
        print("\(navigationAction.request.url?.absoluteString ?? "")" )
        
        decisionHandler(.allow)
    }
}

extension StreamerViewController: WKUIDelegate {

    public func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        
    }
    private func webView(_ webView: WKWebView, shouldPreviewElement elementInfo: WKContextMenuElementInfo) -> Bool {
        // Input 요소를 클릭하여 확대가 발생했을 때, 이벤트를 처리
        return false // 확대 막기
    }
}
