//
//  CalendarUtil.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 1/7/25.
//

import Foundation

struct DayInfo {
    let day: Int
    let dayOfWeek: String
    let displayName: String
    var isDataEmpty: Bool = false
}

enum TimeFormatType {
    case ampm
    case ampmWithDate
}

class CalendarUtil {
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
            
            guard let date = calendar.date(from: components) else { return DayInfo(day: day, dayOfWeek: "", displayName: "") }
            
            let dayOfWeek = calendar.component(.weekday, from: date)
            let dayOfWeekSymbol = calendar.weekdaySymbols[dayOfWeek - 1]
            return DayInfo(day: day, dayOfWeek: dayOfWeekSymbol, displayName: dayOfWeekSymbol)
        }
    }

    static func isSameDate(stringDate: String, selectedYearMonth: String, selectedDay: Int) -> Bool {
        let yearMonthParts = selectedYearMonth.split(separator: "/")
        guard yearMonthParts.count == 2,
              let year = Int("20\(yearMonthParts[0])"),
              let month = Int(yearMonthParts[1]) else {
            return false
        }
        
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: "UTC")!
        
        let components = DateComponents(year: year, month: month, day: selectedDay)
        guard let selectedDate = calendar.date(from: components) else {
            return false
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXXXX"
        dateFormatter.locale = Locale(identifier: "ko_KR")
        guard let stringLocalDate = dateFormatter.date(from: stringDate) else {
            return false
        }
        
        return Calendar.current.isDate(stringLocalDate, inSameDayAs: selectedDate)
    }
    
    static func formatDate(
        date: String,
        formatType: TimeFormatType = .ampmWithDate,
        zoneId: TimeZone = TimeZone(identifier: "Asia/Seoul")!
    ) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        guard let parsedDate = dateFormatter.date(from: date) else {
            return ""
        }
        
        dateFormatter.locale = Locale(identifier: "ko_KR")
        
        if formatType == .ampm {
            dateFormatter.dateFormat = "a hh:mm"
        } else {
            dateFormatter.dateFormat = "yyyy.MM.dd a hh:mm"
            
        }
        dateFormatter.timeZone = zoneId
        
        return dateFormatter.string(from: parsedDate)
    }
}
