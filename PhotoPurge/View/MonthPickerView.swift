//
//  MonthPicker.swift
//  PhotoPurge
//
//  Created by Toan Pham on 1/11/25.
//

import SwiftUI
import Photos

struct MonthPickerView: View {
    @StateObject var monthPickerVM: MonthPickerVM
    @StateObject var navigationPathVM: NavigationPathVM
    
    init(monthPickerVM: MonthPickerVM = .init()) {
        self._monthPickerVM = StateObject(wrappedValue: monthPickerVM)
        self._navigationPathVM = StateObject(wrappedValue: NavigationPathVM())
    }
    
    var body: some View {
        NavigationStack(path: $navigationPathVM.path) {
            ZStack {
                if monthPickerVM.isLoading {
                    ProgressView()
                }
                else {
                    List {
                        // Group by year first
                        ForEach(monthPickerVM.groupedByYear.keys.sorted(), id: \.self) { year in
                            Section(header: YearHeaderView(year: year)) {
                                ForEach(monthPickerVM.groupedByYear[year]!.sorted(by: { $0.key < $1.key }), id: \.key) { monthDate, assets in
                                    monthRow(monthDate: monthDate, assets: assets)
                                }
                            }
                        }
                    }
                }
            }
            .padding()
            .navigationDestination(for: NavigationDestination.self) { destination in
                switch destination {
                case .photoDelete(let assets):
                    PhotoDeleteView(assets: assets, navigationPathVM: navigationPathVM)
                case .result(let deleteResult):
                    ResultView(deleteResult: deleteResult, navigationPathVM: navigationPathVM)
                }
            }
            .navigationTitle("Pick a month")
            .toolbar {
                ToolbarItem {
                    Button {
                        monthPickerVM.getPhotosByMonth()
                    } label: {
                        Text("Reload")
                    }

                }
            }
        }
        .environmentObject(navigationPathVM)
        .task {
            monthPickerVM.getPhotosByMonth()
        }
    }
    
    private func monthRow(monthDate: Date, assets: [PHAsset]) -> some View {
        HStack {
            Button(Util.getMonthString(from: monthDate)) {
                navigationPathVM.navigateTo(.photoDelete(assets))
            }
            Spacer()
            Text("\(assets.count) " + (assets.count > 1 ? "items" : "item"))
        }
    }
}

struct YearHeaderView: View {
    let year: Int
    
    var body: some View {
        Text("\(String(year))")
            .font(.title3)
    }
}

#Preview {
    MonthPickerView(
        monthPickerVM: .init(
            isLoading: false,
            groupedByYear: [
                2025 : [Date(): []],
                2024 : [Calendar.current.date(byAdding: .year, value: -1, to: Date())!: []]
            ]
        )
    )
}

