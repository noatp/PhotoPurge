//
//  ContentView.swift
//  PhotoPurge
//
//  Created by Toan Pham on 1/10/25.
//

import SwiftUI
import Photos
import AVKit

struct PhotoDeleteView: View {
    @EnvironmentObject var navigationPathVM: NavigationPathVM
    @ObservedObject private var viewModel: PhotoDeleteVM
    @State private var shouldShowAlert: Bool = false
    
    init(photoDeleteVM: PhotoDeleteVM) {
        self.viewModel = photoDeleteVM
    }
    
    var body: some View {
        Group {
            if let assetsGroupedByMonth = viewModel.assetsGroupedByMonth {
                VStack {
                    MonthPickerRow(
                        selectedDate: $viewModel.selectedMonth,
                        assetsGroupedByMonth: assetsGroupedByMonth
                    ) { month in
                        viewModel.selectMonth(date: month)
                    }
                    Divider()
                        .padding()
                    ZStack {
                        if let currentDisplayingAsset = viewModel.currentDisplayingAsset {
                            VStack {
                                Spacer()
                                CurrentAssetDisplay(displayingAsset: currentDisplayingAsset)
                                Spacer(minLength: 0)
                                Text(viewModel.subtitle)
                                    .font(.caption)
                                    .padding()
                                if !viewModel.shouldDisableActionButtons {
                                    HStack {
                                        IconActionButton(
                                            iconName: "checkmark",
                                            backgroundColor: .green,
                                            foregroundColor: .white
                                        ) {
                                            viewModel.keepPhoto()
                                        }
                                        
                                        Spacer()
                                        
                                        IconActionButton(
                                            iconName: "trash",
                                            backgroundColor: .red,
                                            foregroundColor: .white
                                        ) {
                                                viewModel.deletePhoto()
                                        }
                                    }
                                }
                                    
                            }
                            
                            VStack {
                                HStack (alignment: .top) {
                                    if viewModel.shouldShowUndoButton {
                                        UndoButton {
                                            viewModel.undoLatestAction()
                                        }
                                    }
                                    Spacer()
                                    if let nextImageUIImage = viewModel.nextImage {
                                        Image(uiImage: nextImageUIImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(maxWidth: 100, maxHeight: 100)
                                            .clipped()
                                            .cornerRadius(8)
                                    }
                                }
                                Spacer()
                            }
                        }
                        else {
                            LoadingIndicator()
                        }
                    }
                }
            }
            else {
                LoadingIndicator()
            }
        }
        .padding()
        .navigationTitle(viewModel.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(content: {
            ToolbarItem {
                Button("Reload") {
                    viewModel.fetchAssets()
                }
            }
        })
        .onChange(of: viewModel.shouldNavigateToResult) { _, newValue in
            guard newValue else { return }
            navigationPathVM.navigateTo(.result)
            viewModel.shouldNavigateToResult = false
        }
        .onChange(of: viewModel.errorMessage, { _, newValue in
            guard newValue != nil else { return }
            shouldShowAlert = true
        })
        .alert(viewModel.errorMessage ?? "", isPresented: $shouldShowAlert) {
            Button("OK", role: .cancel) { }
        }
        .task {
            viewModel.fetchAssets()
        }
    }
}

#Preview {
    let today = Date()
    let oneYearAgo = Calendar.current.date(byAdding: .year, value: -1, to: today)!
    
    let assetsGroupedByMonth: [Date: [PHAsset]] = [
        oneYearAgo: [],
        today: []
    ]
    
    NavigationStack {
        PhotoDeleteView(
            photoDeleteVM: .init(
                assetsGroupedByMonth: assetsGroupedByMonth,
                currentDisplayingAsset: .init(assetType: .photo, image: .init(named: "test2")),
                nextImage: .init(named: "test1"),
                shouldShowUndoButton: false,
                shouldNavigateToResult: false,
                shouldDisableActionButtons: false,
                selectedMonth: today,
                errorMessage: nil,
                subtitle: "2 of 3",
                title: Util.getMonthString(from: today)
            )
        )
    }
}

extension Dependency.Views {
    func photoDeleteView() -> PhotoDeleteView {
        return PhotoDeleteView(
            photoDeleteVM: viewModels.photoDeleteVM()
        )
    }
}
