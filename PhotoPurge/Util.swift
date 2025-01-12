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
}
