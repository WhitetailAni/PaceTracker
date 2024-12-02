//
//  PTTime.swift
//  PaceTracker
//
//  Created by WhitetailAni on 7/26/24.
//

import Foundation

public struct PTTime: Comparable {
    let hour: Int
    let minute: Int
    let period: String?
    
    public init(hour: Int, minute: Int) {
        self.hour = hour
        self.minute = minute
        self.period = nil
    }
    
    public init(timeString: String, period: String) {
        let halves = timeString.split(separator: ":")
        var hour = Int(halves[0])!
        let minute = Int(halves[1])!
        
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        let format: String = formatter.dateFormat
        
        if period == "pm" && (format.contains("H") || format.contains("k")) {
            hour += 12
        }
        self.hour = hour
        self.minute = minute
        self.period = period.uppercased()
    }
    
    public static func < (lhs: PTTime, rhs: PTTime) -> Bool {
        return lhs.hour * 60 + lhs.minute < rhs.hour * 60 + rhs.minute
    }
    
    public static func == (lhs: PTTime, rhs: PTTime) -> Bool {
        return lhs.hour == rhs.hour && lhs.minute == rhs.minute
    }
    
    public static func isItCurrentlyBetween(start: PTTime, end: PTTime) -> Bool {
        let now = Date()
        let calendar = Calendar.current
        let current = PTTime(hour: calendar.component(.hour, from: now), minute: calendar.component(.minute, from: now))
        
        if start < end {
            return start <= current && current < end
        } else {
            return current >= start || current < end
        }
    }
    
    public func stringVersion() -> String {
        var hourString: String = String(hour)
        var minuteString: String = String(minute)
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        let format: String = formatter.dateFormat
        
        if hour < 10 {
            hourString = "0" + String(hour)
        }
        if minute < 10 {
            minuteString = "0" + String(minute)
        }
        
        if !(format.contains("H") || format.contains("k")) {
            return "\(hourString):\(minuteString) \(period ?? "FM")"
        }
        return "\(hourString):\(minuteString)"
    }
}
