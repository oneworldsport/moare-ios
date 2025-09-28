//
//  CalendarUtil.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 1/7/25.
//

import Foundation

struct DayInfo {
    let day: Int
    let dayOfWeek: Int
    let displayName: String
    var isDataEmpty: Bool = false
}

enum TimeFormatType {
    case ampm, ampmWithDate, ampmWithDayOfWeekDate, yearMonth
}

// TODO: struct로 바꾸는게 맞을듯?
class CalendarUtil {
    static let currentYear = Calendar.current.component(.year, from: Date())
    
    enum DefaultYearMonthType {
        case nextYearMonth, currentYearMonth, previousYearMonth
    }
    
    static func getDaysInMonth(year: Int, month: Int, locale: Locale = Locale(identifier: "ko_KR")) -> [DayInfo] {
        var calendar = Calendar.current
        calendar.locale = locale
        
        let dateComponents = DateComponents(year: year, month: month)
        guard let firstDayOfMonth = calendar.date(from: dateComponents),
              let range = calendar.range(of: .day, in: .month, for: firstDayOfMonth) else {
            return []
        }
        
        return range.map { day in
            var components = DateComponents()
            components.year = year
            components.month = month
            components.day = day
            
            guard let date = calendar.date(from: components) else { return DayInfo(day: day, dayOfWeek: 0, displayName: "") }
            
            let dayOfWeek = calendar.component(.weekday, from: date)
            let dayOfWeekSymbol = calendar.shortWeekdaySymbols[dayOfWeek - 1]
            return DayInfo(day: day, dayOfWeek: dayOfWeek, displayName: dayOfWeekSymbol)
        }
    }

    static func isSameDate(stringDate: String, selectedYearMonth: String, selectedDay: Int) -> Bool {
        let yearMonthParts = selectedYearMonth.split(separator: "/")
        guard yearMonthParts.count == 2,
              let year = Int("20\(yearMonthParts[0])"),
              let month = Int(yearMonthParts[1]) else {
            return false
        }
        
//        var calendar = Calendar.current
//        calendar.timeZone = TimeZone(identifier: "UTC")!
        
        let components = DateComponents(year: year, month: month, day: selectedDay)
        guard let selectedDate = Calendar.current.date(from: components) else {
            return false
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXXXX"
//        dateFormatter.locale = Locale(identifier: "ko_KR")
        guard let parsedDate = dateFormatter.date(from: stringDate) else {
            return false
        }
        
        return Calendar.current.isDate(parsedDate, inSameDayAs: selectedDate)
    }
    
    static func formatDate(
        date: String?,
        formatType: TimeFormatType = .ampmWithDate,
        zoneId: TimeZone = TimeZone(identifier: "Asia/Seoul")!
    ) -> String {
        guard let date = date, !date.isEmpty else { return "" }
        
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        inputFormatter.locale = Locale(identifier: "en_US_POSIX") // NOTE: 예상치 못한 오류 방지위해 설정 권장 - by gpt
        
        guard let parsedDate = inputFormatter.date(from: date) else {
            return ""
        }
        
        let outputFormatter = DateFormatter()
        outputFormatter.locale = Locale(identifier: "ko_KR")
        outputFormatter.timeZone = zoneId
        
        switch formatType {
        case .ampm: outputFormatter.dateFormat = "a hh:mm"
        case .ampmWithDate: outputFormatter.dateFormat = "yyyy.MM.dd a hh:mm"
        case .ampmWithDayOfWeekDate: outputFormatter.dateFormat = "yyyy.MM.dd (E) a hh:mm"
        case .yearMonth: outputFormatter.dateFormat = "yy/MM"
        }
        
        return outputFormatter.string(from: parsedDate)
    }
    
    static func getDefaultDay(yearMonth: String, dayList: [DayInfo]) -> (Int, DayInfo)? {
        let defaultYearMonthType = getDefaultYearMonthType(yearMonth: yearMonth)
        
        switch defaultYearMonthType {
        case .currentYearMonth:
            // Return closest future day that has games.
            // If there are no matching days, get the last day that has games from the current month.
            let currentDay = Calendar.current.component(.day, from: Date())
           
            if let result = dayList.enumerated().first(where: { $0.element.day >= currentDay && !$0.element.isDataEmpty }) {
                return (result.offset, result.element)
            } else if let result = Array(dayList.enumerated()).last(where: { !$0.element.isDataEmpty }) {
                return (result.offset, result.element)
            }
            
        case .nextYearMonth:
            if let result = dayList.enumerated().first(where: { !$0.element.isDataEmpty }) {
                return (result.offset, result.element)
            }
            
        case .previousYearMonth:
            if let result = Array(dayList.enumerated()).last(where: { !$0.element.isDataEmpty }) {
                return (result.offset, result.element)
            }
        }
        
        return nil
    }
    
    static func getDefaultYearMonthType(yearMonth: String) -> DefaultYearMonthType {
        let currentDate = Date()
        let calendar = Calendar(identifier: .gregorian)
        
        let currentYear = calendar.component(.year, from: currentDate) % 100
        let currentMonth = calendar.component(.month, from: currentDate)
        let totalCurrentYearMonth = currentYear * 12 + currentMonth
        
        let components = yearMonth.split(separator: "/")
        
        guard components.count == 2,
              let year = Int(components[0]),
              let month = Int(components[1]) else {
            return .currentYearMonth
        }
        
        let totalYearMonth = year * 12 + month
        
        switch totalYearMonth {
        case totalCurrentYearMonth:
            return .currentYearMonth
        case _ where totalYearMonth > totalCurrentYearMonth:
            return .nextYearMonth
        default:
            return .previousYearMonth
        }
    }
    
    static func calculateAge(from birthDate: String) -> Int {
        var birthDateString = birthDate
        
        if birthDateString.contains("T") {
            birthDateString = birthDateString.components(separatedBy: "T").first ?? ""
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        guard let parsedBirthDate = formatter.date(from: birthDateString) else {
            return 0
        }
        
        let calendar = Calendar.current
        let now = Date()
        
        var age = calendar.dateComponents([.year], from: parsedBirthDate, to: now).year ?? 0
        
        // 올해 생일
        // parsedBirthDate에서 연도만 올해로 바꿔주는 작업
        let birthDayThisYear = calendar.date(
            bySetting: .year, // 설정할 항목: 연도
            value: calendar.component(.year, from: now), // 설정할 값: 현재 연도
            of: parsedBirthDate // 기준(반영할) 값
        )
        
        if let birthDayThisYear, birthDayThisYear > now {
            age -= 1 // 생일 아직 안 지났음
        }
        
        return age
    }
    
    static func formatMinutesToHourMinute(min: Int) -> String {
        let hours = min / 60
        let minutes = min % 60
        return "\(hours):\(minutes)"
    }
    
    static func formatHourMinuteToMinutes(time: String) -> Int {
        let parts = time.components(separatedBy: ":")
        if parts.count == 2,
           let hours = Int(parts[0]),
           let minutes = Int(parts[1]) {
            return (hours * 60) + minutes
        } else {
            return 0
        }
    }
    
    static func isUpcomingDay(date: String) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        guard let gameDate = dateFormatter.date(from: date) else {
                return false
        }
        
        let today = Date()
        
        return gameDate >= today
    }
    
    static func timeAgoString(from dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")!
        
        guard let date = formatter.date(from: dateString) else {
            return dateString
        }
        
        let now = Date()
        let diff = now.timeIntervalSince(date) // 초 단위 차이
        if diff < 60 { // 1분 미만
            return "방금 전"
        }
        
        let minutes = Int(diff / 60)
        if minutes < 60 {
            return "\(minutes)분 전"
        }
        
        let hours = Int(diff / 3600)
        if hours < 24 {
            return "\(hours)시간 전"
        }
        
        let days = Int(diff / 86400)
        if days < 7 {
            return "\(days)일 전"
        }
        
        let weeks = Int(days / 7)
        if weeks < 4 {
            return "\(weeks)주 전"
        }
        
        let months = Int(days / 30)
        if months < 12 {
            return "\(months)개월 전"
        }
        
        let years = Int(days / 365)
        return "\(years)년 전"
    }
}
