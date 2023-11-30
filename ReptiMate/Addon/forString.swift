//
//  forString.swift
//  ReptiMate
//
//  Created by 김기용 on 2023/05/09.
//

import Foundation
extension String {
    func substring(from: Int, to: Int) -> String {
        guard from < count, to >= 0, to - from >= 0 else {
            return ""
        }
        
        // Index 값 획득
        let startIndex = index(self.startIndex, offsetBy: from)
        let endIndex = index(self.startIndex, offsetBy: to + 1) // '+1'이 있는 이유: endIndex는 문자열의 마지막 그 다음을 가리키기 때문
        
        // 파싱
        return String(self[startIndex ..< endIndex])
    }
    func clipDateString() -> String {
        let fullDate = self
        var Year = fullDate.substring(from: 2, to: 3)
        var Month = ""
        var Day = ""
        if fullDate.substring(from: 5, to: 5) == "0" {
            Month = fullDate.substring(from: 6, to: 6)
        } else {
            Month = fullDate.substring(from: 5, to: 6)
        }
        if fullDate.substring(from: 8, to: 8) == "0" {
            Day = fullDate.substring(from: 9, to: 9)
        } else {
            Day = fullDate.substring(from: 8, to: 9)
        }
        
        var clippedDate = "\(String(describing: Month))/\(String(describing: Day))"
        
        return clippedDate
    }
}
extension String {
    func toDate() -> Date? { //"yyyy-MM-dd HH:mm:ss"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        if let date = dateFormatter.date(from: self) {
            return date
        } else {
            return nil
        }
    }
    func toDateOnly() -> Date? { //"yyyy-MM-dd HH:mm:ss"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = NSTimeZone(name: "ko_KR") as TimeZone?
        if let date = dateFormatter.date(from: self) {
            return date
        } else {
            return nil
        }
    }
}

extension Date {
    func toString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        return dateFormatter.string(from: self)
    }
    func toStringOnly() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = NSTimeZone(name: "ko_KR") as TimeZone?
        return dateFormatter.string(from: self)
    }
}
