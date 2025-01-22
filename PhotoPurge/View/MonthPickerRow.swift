//
//  MonthPickerRow.swift
//  PhotoPurge
//
//  Created by Toan Pham on 1/21/25.
//

import SwiftUI
import Photos

struct MonthPickerRow: View {
    private let assetsGroupedByMonth: [Date: [PHAsset]]
    
    init(assetsGroupedByMonth: [Date : [PHAsset]]) {
        self.assetsGroupedByMonth = assetsGroupedByMonth
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 20) {
                ForEach(assetsGroupedByMonth.keys.sorted(), id: \.self) { date in
                    MonthPickerButton(date: date, assetsGroupedByMonth: assetsGroupedByMonth)
                }
            }
            .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct MonthPickerButton: View {
    private let date: Date
    private let assetsGroupedByMonth: [Date: [PHAsset]]
    
    init(date: Date, assetsGroupedByMonth: [Date : [PHAsset]]) {
        self.date = date
        self.assetsGroupedByMonth = assetsGroupedByMonth
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Text(Util.getYear(from: date))
                .font(.headline)
            Text(Util.getShortMonth(from: date))
                .font(.title2)
                .padding(.bottom, 5)
            Text("\(assetsGroupedByMonth[date]?.count ?? 0) items")
                .font(.caption)
        }
        .padding(4)
        .background(RoundedRectangle(cornerRadius: 8).fill(Color.secondary.opacity(0.3)))
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    let today = Date()
    let oneYearAgo = Calendar.current.date(byAdding: .year, value: -1, to: today)!
    
    // Explicitly define the type of the dictionary
    let assetsGroupedByMonth: [Date: [PHAsset]] = [
        oneYearAgo: [],
        today: []
    ]
    
    MonthPickerRow(assetsGroupedByMonth: assetsGroupedByMonth)
}
