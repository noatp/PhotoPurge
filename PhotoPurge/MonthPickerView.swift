//
//  MonthPicker.swift
//  PhotoPurge
//
//  Created by Toan Pham on 1/11/25.
//

import SwiftUI
import Photos

struct MonthPickerView: View {   // Use generics to specify the protocol type
    @StateObject var monthPickerVM: MonthPickerVM
    @StateObject var navigationPathVM: NavigationPathVM
    
    init() {
        self._monthPickerVM = StateObject(wrappedValue: MonthPickerVM())
        self._navigationPathVM = StateObject(wrappedValue: NavigationPathVM())
    }
        
    var body: some View {
        NavigationStack(path: $navigationPathVM.path) {
            ZStack {
                if monthPickerVM.isLoading {
                    ProgressView()
                }
                else {
                    ScrollView {
                        LazyVStack {
                            ForEach(monthPickerVM.photoGroups.keys.sorted(), id: \.self) { date in
                                Button(Util.getMonthString(from: date)) {
                                    navigationPathVM.navigateTo(.photoDelete(monthPickerVM.photoGroups[date]))
                                }
                                Divider()
                            }
                        }
                    }
                }
            }
            .padding()
            .navigationDestination(for: NavigationDestination.self) { destination in
                switch destination {
                case .photoDelete(let photoAssets):
                    PhotoDeleteView(photoAssets: photoAssets, navigationPathVM: navigationPathVM)
                case .result(let numPhotoDeleted):
                    ResultView(numberOfPhotosRemoved: numPhotoDeleted, navigationPathVM: navigationPathVM)
                }
                
            }
            .navigationTitle("Pick a month")
        }
        .environmentObject(navigationPathVM)
        .task {
            monthPickerVM.getPhotosByMonth()
        }
    }
}

#Preview {
    MonthPickerView()
}
