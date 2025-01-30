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
    @State private var shouldShowAndAnimatePhotoPanal: Bool = false
    @State private var isShowingSideMenu: Bool = false
    
    private let views: Dependency.Views
    
    init(viewModel: PhotoDeleteVM, views: Dependency.Views) {
        self.viewModel = viewModel
        self.views = views
    }
    
    var body: some View {
        ZStack {
            Group {
                if let assetsGroupedByMonth = viewModel.assetsGroupedByMonth {
                    if !assetsGroupedByMonth.isEmpty {
                        VStack {
                            MonthPickerRow(
                                selectedDate: $viewModel.selectedMonth,
                                assetsGroupedByMonth: assetsGroupedByMonth
                            ) { month in
                                viewModel.selectMonth(date: month)
                            }
                            Divider()
                                .padding(.bottom, 8)
                            photoPanel
                        }
                    }
                    else {
                        noPhotosWarningView
                    }
                }
                else {
                    LoadingIndicator()
                }
            }
            SideMenu(isShowingSideMenu: $isShowingSideMenu)
        }
        
        .navigationTitle(viewModel.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Reload") {
                    viewModel.fetchAssets()
                }
            }
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    withAnimation {
                        isShowingSideMenu.toggle()
                    }
                } label: {
                    Image(systemName: "line.3.horizontal")
                        
                        .padding(.vertical)
                }
            }
        }
        .toolbar(isShowingSideMenu ? .hidden : .visible, for: .navigationBar)
        .onChange(of: viewModel.errorMessage) { _, newValue in
            guard newValue != nil else { return }
            shouldShowAlert = true
        }
        .onChange(of: viewModel.currentDisplayingAsset, { oldValue, newValue in
            shouldShowAndAnimatePhotoPanal = newValue != nil
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
            if shouldShowAndAnimatePhotoPanal {
                if let currentDisplayingAsset = viewModel.currentDisplayingAsset {
                    ZStack {
                        VStack {
                            Spacer(minLength: 0)
                            CurrentAssetDisplay(
                                displayingAsset: currentDisplayingAsset,
                                views: views
                            )
                            .padding(.horizontal, 8)
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
        .animation(.easeInOut, value: shouldShowAndAnimatePhotoPanal)
        
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
                        .padding(.bottom)
                    LabelActionButton(
                        labelText: "Confirm",
                        backgroundColor: .accentColor,
                        foregroundColor: .white
                    ) {
                        viewModel.deletePhotoFromDevice()
                    }
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
    
    var noPhotosWarningView: some View {
        VStack {
            Text("No Accessible Photos Found")
                .font(.title2)
                .bold()
                .padding()
            
            Text("We couldn’t find any photos you’ve granted access to. Please allow full photo access or select specific photos and tap \"Reload\" to continue.")
                .font(.headline)
                .padding()
            Button {
                viewModel.openSettings()
            } label: {
                Text("Go to settings")
                    .font(.headline)
            }
            .padding()
        
        }
        .multilineTextAlignment(.center)
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
                assetsGroupedByMonth: [:],
                currentDisplayingAsset: .init(assetType: .photo, image: .init(named: "test1")),
                nextImage: .init(named: "test1"),
                shouldShowUndoButton: false,
                shouldNavigateToResult: false,
                actionButtonState: .confirmDelete,
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
