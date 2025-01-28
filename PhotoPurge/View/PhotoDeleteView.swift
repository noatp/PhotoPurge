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
    @State private var shouldShowAndAnimatePhotoPanale: Bool = false
    
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
        .onChange(of: viewModel.currentDisplayingAsset, { oldValue, newValue in
            shouldShowAndAnimatePhotoPanale = newValue != nil
        })
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
    
    var photoPanel: some View {
        ZStack {
            if shouldShowAndAnimatePhotoPanale {
                if let currentDisplayingAsset = viewModel.currentDisplayingAsset {
                    ZStack {
                        VStack {
                            Spacer(minLength: 0)
                            CurrentAssetDisplay(
                                displayingAsset: currentDisplayingAsset,
                                views: views
                            )
                            Spacer(minLength: 0)
                            subtitle
                            Divider()
                            actionButtonBar
                        }
                        nextImageOverlay
                        undoButtonOverlay
                    }
                    .transition(.opacity)
                }
            }
            else {
                LoadingIndicator()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut, value: shouldShowAndAnimatePhotoPanale)
        
    }
    
    var nextImageOverlay: some View {
        VStack {
            HStack (alignment: .top) {
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
            .padding(.top, 8)
            Spacer()
        }
    }
    
    var undoButtonOverlay: some View {
        VStack {
            HStack {
                if viewModel.shouldShowUndoButton {
                    UndoButton {
                        viewModel.undoLatestAction()
                    }
                    .padding(.leading)
                    .zIndex(1)
                    .transition(.move(edge: .leading))
                }
                Spacer()
            }
            .padding(.top, 8)
            .animation(.easeInOut, value: viewModel.shouldShowUndoButton)
            
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
                .transition(.move(edge: .bottom))
                
            case .confirmDelete:
                VStack(spacing: 0) {
                    Text("You selected \(viewModel.assetsToDelete.count) items to delete.")
                        .font(.headline)
                    
                    Button {
                        viewModel.deletePhotoFromDevice()
                    } label: {
                        Text("Confirm")
                            .font(.headline)
                            .frame(maxWidth: .infinity, maxHeight: 44)
                            .foregroundColor(.white)
                    }
                    .background(Color.accentColor)
                    .cornerRadius(8)
                    .padding()
                }
                .transition(.move(edge: .bottom))
                
            case .hide:
                EmptyView()
                    .transition(.move(edge: .bottom))
            case .ads:
                VStack(spacing: 0) {
                    LabelActionButton(
                        labelText: "Skip",
                        backgroundColor: .accentColor,
                        foregroundColor: .white
                    ) {
                        viewModel.skipAds()
                    }
                }
                .transition(.move(edge: .bottom))
            }
            
        }
        .animation(.easeInOut, value: viewModel.actionButtonState)
        .padding(.horizontal)
    }
    
    var subtitle: some View {
        ZStack {
            if let subtitle = viewModel.subtitle {
                Text(subtitle)
                    .font(.caption)
                    .padding(.top, 8)
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
                currentDisplayingAsset: .init(assetType: .photo, image: .init(named: "test1")),
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
