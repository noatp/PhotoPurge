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
    @State private var shouldShowAndAnimateActionButtons: Bool = true
    @State private var shouldShowAndAnimateUndoButton: Bool = false
    
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
                        .padding()
                    ZStack {
                        if let currentDisplayingAsset = viewModel.currentDisplayingAsset {
                            VStack {
                                Spacer()
                                CurrentAssetDisplay(displayingAsset: currentDisplayingAsset)
                                Spacer(minLength: 0)
                                Text(viewModel.subtitle)
                                    .font(.caption)
                                    .padding(.top)
                                Divider()
                                if shouldShowAndAnimateActionButtons {
                                    actionButtonBar
                                }
                                else {
                                    confirmDeleteButtonBar
                                }
                                
                            }
                            
                            nextImageOverlay
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
        .onChange(of: viewModel.shouldDisableActionButtons) { _, shouldDisable in
            withAnimation(.easeInOut(duration: 0.2)) {
                shouldShowAndAnimateActionButtons = !shouldDisable
            }
        }
        .onChange(of: viewModel.shouldShowUndoButton) { _, shouldShowUndoButton in
            withAnimation(.easeInOut(duration: 0.2)) {
                shouldShowAndAnimateUndoButton = shouldShowUndoButton
            }
        }
        .alert(viewModel.errorMessage ?? "", isPresented: $shouldShowAlert) {
            Button("OK", role: .cancel) { viewModel.resetErrorMessage() }
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
                if shouldShowAndAnimateUndoButton {
                    UndoButton {
                        viewModel.undoLatestAction()
                    }
                    .transition(.move(edge: .leading))
                    .padding(.leading)
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
        .padding(.horizontal)
    }
    
    var confirmDeleteButtonBar: some View {
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
        .transition(.move(edge: .bottom))
        .padding(.horizontal)
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
                shouldDisableActionButtons: false,
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
