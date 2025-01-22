////
////  MonthPicker.swift
////  PhotoPurge
////
////  Created by Toan Pham on 1/11/25.
////
//
//import SwiftUI
//import Photos
//
//struct MonthPickerView: View {
//    @StateObject private var monthPickerVM: MonthPickerVM
//    
//    private let views: Dependency.Views
//    
//    init(
//        monthPickerVM: MonthPickerVM,
//        views: Dependency.Views
//    ) {
//        self._monthPickerVM = StateObject(wrappedValue: monthPickerVM)
//        self.views = views
//    }
//    
//    var body: some View {
//        NavigationStack(path: $navigationPathVM.path) {
//            if let isLoading = monthPickerVM.isLoading,
//               let assetsGroupedByMonthYear = monthPickerVM.assetsGroupedByMonthYear
//            {
//                ZStack {
//                    if isLoading {
//                        ProgressView()
//                    }
//                    else {
//                        AssetList(assetsGroupedByMonthYear: assetsGroupedByMonthYear) { selectedDate in
//                            monthPickerVM.selectMonthWithDate(selectedDate)
//                            
//                        }
//                    }
//                }
//                .padding()
//                .navigationDestination(for: NavigationDestination.self) { destination in
//                    switch destination {
//                    case .photoDelete:
//                        views.photoDeleteView()
//                    case .result:
//                        views.resultView()
//                    }
//                }
//                .navigationTitle("Pick a month")
//                .toolbar {
//                    ToolbarItem {
//                        Button {
//                            monthPickerVM.fetchAsset()
//                        } label: {
//                            Text("Reload")
//                        }
//                        
//                    }
//                }
//            }
//            
//        }
//        .environmentObject(navigationPathVM)
//        .task {
//            monthPickerVM.fetchAsset()
//        }
//        .onChange(of: navigationPathVM.path) { _, newValue in
//            if newValue == [] {
//                monthPickerVM.fetchAsset()
//            }
//        }
//    }
//}
//
//struct AssetList: View {
//    let assetsGroupedByMonthYear: [Int: [Date: [PHAsset]]]
//    let selectMonthWithDate: (Date) -> Void
//    
//    var body: some View {
//        List {
//            // Group by year first
//            ForEach(assetsGroupedByMonthYear.keys.sorted(), id: \.self) { year in
//                YearSectionView(year: year, assetsGroupedByMonthYear: assetsGroupedByMonthYear) { selectedDate in
//                    selectMonthWithDate(selectedDate)
//                }
//            }
//        }
//    }
//}
//
//struct YearSectionView: View {
//    let year: Int
//    let assetsGroupedByMonthYear: [Int: [Date: [PHAsset]]]
//    let selectMonthWithDate: (Date) -> Void
//
//    var body: some View {
//        Section(header: YearHeaderView(year: year)) {
//            if let months = assetsGroupedByMonthYear[year] {
//                ForEach(months.sorted(by: { $0.key < $1.key }), id: \.key) { monthDate, assets in
//                    MonthRow(date: monthDate, assets: assets) { selectedDate in
//                        selectMonthWithDate(selectedDate)
//                    }
//                }
//            }
//        }
//    }
//}
//
//struct YearHeaderView: View {
//    let year: Int
//    
//    var body: some View {
//        Text("\(String(year))")
//            .font(.title3)
//    }
//}
//
//struct MonthRow: View {
//    @EnvironmentObject var navigationPathVM: NavigationPathVM
//    
//    let date: Date
//    let assets: [PHAsset]
//    let selectMonthWithDate: (Date) -> Void
//    
//    var body: some View {
//        HStack {
//            Button(Util.getMonthString(from: date)) {
//                selectMonthWithDate(date)
//                navigationPathVM.navigateTo(.photoDelete(.init(date: date, assets: assets)))
//            }
//            Spacer()
//            Text("\(assets.count) " + (assets.count > 1 ? "items" : "item"))
//        }
//    }
//}
//
//#Preview {
//    let previewAssetGroupByMonthYear: [Int: [Date: [PHAsset]]] = [2025: [Date(): []]]
//    
//    MonthPickerView(
//        monthPickerVM: .init(isLoading: false, assetsGroupedByMonthYear: previewAssetGroupByMonthYear),
//        views: Dependency.preview.views()
//    )
//}
//
//extension Dependency.Views {
//    func monthPickerView() -> MonthPickerView {
//        return MonthPickerView(
//            monthPickerVM: viewModels.monthPickerVM(),
//            views: self
//        )
//    }
//}
