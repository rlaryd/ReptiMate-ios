////
////  NotificationService.swift
////  NotificationServiceExtension
////
////  Created by 김기용 on 2023/11/06.
////
//
//import UserNotifications
//
//class NotificationService: UNNotificationServiceExtension {
//
//    var contentHandler: ((UNNotificationContent) -> Void)?
//    var bestAttemptContent: UNMutableNotificationContent?
//
//    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
//        self.contentHandler = contentHandler
//        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
//
//        guard let bestAttemptContent else { return }
//
//        bestAttemptContent.title = "변경 " + request.content.title
//
//        if let bestAttemptContent = bestAttemptContent {
////             수신한 알림 내용을 수정합니다.
//            if let userInfo = bestAttemptContent.userInfo as? [String: Any] {
//                    if let body = userInfo["body"] as? String {
//                        print("Original Body: \(bestAttemptContent.body)")
//                        if let data = body.data(using: .utf8) {
//                            do {
//                                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
//                                   let description = json["description"] as? String {
//                                    // "description" 필드의 값을 가져옵니다.
//                                    print(description) // 출력: hello
//                                    bestAttemptContent.body = description
//                                }
//                            } catch {
//                                print("JSON 파싱 오류: \(error)")
//                            }
//                        }
//                    }
//                }
////             다른 수정 작업 수행 가능
//            contentHandler(bestAttemptContent)
//        }
//    }
//
//    override func serviceExtensionTimeWillExpire() {
//        // Called just before the extension will be terminated by the system.
//        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
//        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
//            contentHandler(bestAttemptContent)
//        }
//    }
//
//}
