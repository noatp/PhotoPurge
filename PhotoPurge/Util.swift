//
//  Util.swift
//  PhotoPurge
//
//  Created by Toan Pham on 1/11/25.
//

import Foundation

struct Util {
    static func getMonthString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM, yyyy" // Format: April, 2025
        return formatter.string(from: date)
    }
    
    static func startOfMonth(from date: Date) -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: date)
        return calendar.date(from: components)!
    }
    
    static func getYear(from date: Date) -> Int {
        let calendar = Calendar.current
        return calendar.component(.year, from: date)
    }
    
    static func convertByteToHumanReadable(_ bytes:Int64) -> String {
        let formatter:ByteCountFormatter = ByteCountFormatter()
        formatter.countStyle = .binary
        
        return formatter.string(fromByteCount: Int64(bytes))
    }
    
    static func getShortMonth(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM"  // Short month format (e.g., "Jan")
        return dateFormatter.string(from: date)
    }

    static func getYear(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"  // Full 4-digit year
        return dateFormatter.string(from: date)
    }
}
