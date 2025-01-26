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
    @ObservedObject private var viewModel: PhotoDeleteVM
    @State private var shouldShowAlert: Bool = false
    
    private let views: Dependency.Views
    
    init(viewModel: PhotoDeleteVM, views: Dependency.Views) {
        self.viewModel = viewModel
        self.views = views
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
                    photoPanel
                }
            }
            else {
                LoadingIndicator()
            }
        }
        .navigationTitle(viewModel.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(content: {
            ToolbarItem {
                Button("Reload") {
                    viewModel.fetchAssets()
                }
            }
        })
        .onChange(of: viewModel.errorMessage) { _, newValue in
            guard newValue != nil else { return }
            shouldShowAlert = true
        }
        .animation(.easeInOut, value: viewModel.actionButtonState)
        .animation(.easeInOut, value: viewModel.shouldShowUndoButton)

        .alert(viewModel.errorMessage ?? "", isPresented: $shouldShowAlert) {
            Button("OK", role: .cancel) {
                if viewModel.shouldSelectNextMonth {
                    viewModel.selectNextMonth()
                    viewModel.shouldSelectNextMonth = false
                }
                viewModel.resetErrorMessage()
            }
        }
        .navigationDestination(isPresented: $viewModel.shouldNavigateToResult) {
            views.resultView()
        }
        .task {
            viewModel.fetchAssets()
        }
    }
    
    var nextImageOverlay: some View {
        VStack {
            HStack (alignment: .top) {
                if viewModel.shouldShowUndoButton {
                    UndoButton {
                        viewModel.undoLatestAction()
                    }
                    .transition(.move(edge: .leading))
                    .padding(.leading)
                    .zIndex(1)  // Ensure this is above the video player
                }
                Spacer()
                if let nextImageUIImage = viewModel.nextImage {
                    Image(uiImage: nextImageUIImage)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: 100, maxHeight: 100)
                        .clipped()
                        .cornerRadius(8)
                        .padding(.trailing)
                }
            }
            Spacer()
        }
    }
    
    var actionButtonBar: some View {
        Group {
            switch viewModel.actionButtonState {
            case .show:
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
            case .confirmDelete:
                VStack {
                    Text("You selected \(viewModel.assetsToDelete.count) items to delete.")
                        .font(.title3)
                        .padding()

                    Button {
                        viewModel.deletePhotoFromDevice()
                    } label: {
                        Text("Confirm")
                            .font(.title3)
                            .frame(maxWidth: .infinity, maxHeight: 44)
                            .foregroundColor(.white)
                            .padding()
                    }
                    .background(Color.accentColor)
                    .cornerRadius(8)
                    .padding()
                }
            case .hideForAds:
                EmptyView()
            }
        }
        .transition(.move(edge: .bottom))
        .padding(.horizontal)
    }
    
    var photoPanel: some View {
        Group {
            if let currentDisplayingAsset = viewModel.currentDisplayingAsset {
                ZStack {
                    VStack {
                        Spacer()
                        CurrentAssetDisplay(displayingAsset: currentDisplayingAsset)
                        Spacer(minLength: 0)
                        Text(viewModel.subtitle)
                            .font(.caption)
                            .padding(.top)
                        Divider()
                        actionButtonBar
                    }
                    nextImageOverlay
                }
            }
            else {
                LoadingIndicator()
            }
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
            viewModel: .init(
                assetsGroupedByMonth: assetsGroupedByMonth,
                currentDisplayingAsset: .init(assetType: .photo, image: .init(named: "test2")),
                nextImage: .init(named: "test1"),
                shouldShowUndoButton: false,
                shouldNavigateToResult: false,
                actionButtonState: .show,
                selectedMonth: today,
                errorMessage: nil,
                subtitle: "2 of 3",
                title: Util.getMonthString(from: today)
            ),
            views: Dependency.preview.views()
        )
    }
}

extension Dependency.Views {
    func photoDeleteView() -> PhotoDeleteView {
        return PhotoDeleteView(
            viewModel: viewModels.photoDeleteVM(),
            views: self
        )
    }
}
