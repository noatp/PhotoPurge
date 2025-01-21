//
//  MonthPicker.swift
//  PhotoPurge
//
//  Created by Toan Pham on 1/11/25.
//

import SwiftUI
import Photos

struct MonthPickerView: View {
    @StateObject private var monthPickerVM: MonthPickerVM
    @StateObject private var navigationPathVM: NavigationPathVM = .init()
    
    private let views: Dependency.Views
    
    init(
        monthPickerVM: MonthPickerVM,
        views: Dependency.Views
    ) {
        self._monthPickerVM = StateObject(wrappedValue: monthPickerVM)
        self.views = views
    }
    
    var body: some View {
        NavigationStack(path: $navigationPathVM.path) {
            if let isLoading = monthPickerVM.isLoading,
               let assetsGroupedByMonthYear = monthPickerVM.assetsGroupedByMonthYear
            {
                ZStack {
                    if isLoading {
                        ProgressView()
                    }
                    else {
                        AssetList(assetsGroupedByMonthYear: assetsGroupedByMonthYear)
                    }
                }
                .padding()
                .navigationDestination(for: NavigationDestination.self) { destination in
                    switch destination {
                    case .photoDelete(let assetsToDelete):
                        PhotoDeleteView(assetsToDelete: assetsToDelete, navigationPathVM: navigationPathVM)
                    case .result(let deleteResult):
                        ResultView(deleteResult: deleteResult, navigationPathVM: navigationPathVM)
                    }
                }
                .navigationTitle("Pick a month")
                .toolbar {
                    ToolbarItem {
                        Button {
                            monthPickerVM.fetchAsset()
                        } label: {
                            Text("Reload")
                        }
                        
                    }
                }
            }
            
        }
        .environmentObject(navigationPathVM)
        .task {
            monthPickerVM.fetchAsset()
        }
        .onChange(of: navigationPathVM.path) { _, newValue in
            if newValue == [] {
                monthPickerVM.fetchAsset()
            }
        }
    }
}

struct AssetList: View {
    let assetsGroupedByMonthYear: [Int: [Date: [PHAsset]]]
    
    var body: some View {
        List {
            // Group by year first
            ForEach(assetsGroupedByMonthYear.keys.sorted(), id: \.self) { year in
                YearSectionView(year: year, assetsGroupedByMonthYear: assetsGroupedByMonthYear)
            }
        }
    }
}

struct YearSectionView: View {
    let year: Int
    let assetsGroupedByMonthYear: [Int: [Date: [PHAsset]]]

    var body: some View {
        Section(header: YearHeaderView(year: year)) {
            if let months = assetsGroupedByMonthYear[year] {
                ForEach(months.sorted(by: { $0.key < $1.key }), id: \.key) { monthDate, assets in
                    MonthRow(date: monthDate, assets: assets)
                }
            }
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

struct MonthRow: View {
    @EnvironmentObject var navigationPathVM: NavigationPathVM
    
    let date: Date
    let assets: [PHAsset]
    
    var body: some View {
        HStack {
            Button(Util.getMonthString(from: date)) {
                navigationPathVM.navigateTo(.photoDelete(.init(date: date, assets: assets)))
            }
            Spacer()
            Text("\(assets.count) " + (assets.count > 1 ? "items" : "item"))
        }
    }
}

#Preview {
    let previewAssetGroupByMonthYear: [Int: [Date: [PHAsset]]] = [2025: [Date(): []]]
    
    MonthPickerView(
        monthPickerVM: .init(isLoading: false, assetsGroupedByMonthYear: previewAssetGroupByMonthYear),
        views: Dependency.preview.views()
    )
}

extension Dependency.Views {
    func monthPickerView() -> MonthPickerView {
        return MonthPickerView(
            monthPickerVM: viewModels.monthPickerVM(),
            views: self
        )
    }
}
