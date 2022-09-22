import Foundation

public extension Date {
    func adding(minutes: Int) -> Date {
        Calendar.current.date(byAdding: DateComponents(minute: minutes), to: self)!
    }
}

public extension Date {
    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        lhs.timeIntervalSince(rhs)
    }

    static func + (lhs: Date, rhs: TimeInterval) -> Date {
        lhs.addingTimeInterval(rhs)
    }
}

public extension Date {
    func startOfDay(in calendar: Calendar? = nil) -> Date {
        let calender = calendar ?? Calendar.current
        let components = calender.dateComponents([.era, .year, .month, .day, .timeZone], from: self)
        let date = calender.date(from: components)!
        return date
    }

    func addingDays(_ days: Int, in calendar: Calendar? = nil) -> Date {
        let calendar: Calendar = calendar ?? Calendar.current
        var components = DateComponents()
        components.day = days
        return calendar.date(byAdding: components, to: self)!
    }
}

public extension Date {
    func formatted(with formatter: DateFormatter? = nil) -> String {
        let formatter = formatter ?? DateFormatter.formatter
        return formatter.string(from: self)
    }
}
