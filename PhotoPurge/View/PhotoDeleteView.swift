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
                                currentAsset(currentDisplayingAsset)
                                Spacer(minLength: 0)
                                subtitle
                                    .padding()
                                keepDeleteButtonBar
                            }
                            
                            VStack {
    //                            Spacer()
    //                                .frame(height: 32)
                                HStack (alignment: .top) {
                                    if viewModel.shouldShowUndoButton {
                                        undoButton
                                    }
                                    Spacer()
                                    nextImage
                                }
                                Spacer()
                            }
                        }
                        else {
                            progressPanel
                        }
                    }
                }
            }
            else {
                progressPanel
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
    
    var progressPanel: some View {
        VStack {
            Spacer()
            ProgressView()
            Spacer()
        }
    }
    
    var undoButton: some View {
        Button {
            viewModel.undoLatestAction()
        } label: {
            Image(systemName: "arrow.uturn.backward")
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .foregroundColor(.white)
                .padding()
        }
        .background(Color.gray)
        .cornerRadius(8)
    }
    
    var keepDeleteButtonBar: some View {
        HStack {
            Button {
                viewModel.keepPhoto()
            } label: {
                Image(systemName: "checkmark")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: 44)
                    .foregroundColor(.white)
                    .padding(.vertical)
            }
            .background(Color.green)
            .cornerRadius(8)
            
            Spacer()
            
            Button {
                viewModel.deletePhoto()
            } label: {
                Image(systemName: "trash")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: 44)
                    .foregroundColor(.white)
                    .padding(.vertical)
            }
            .background(Color.red)
            .cornerRadius(8)
        }
    }
    
    var nextImage: some View {
        Group {
            if let nextImageUIImage = viewModel.nextImage {
                Image(uiImage: nextImageUIImage)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: 100, maxHeight: 100)
                    .clipped()
                    .cornerRadius(8)
            } else {
                EmptyView()
            }
        }
    }
    
    var subtitle: some View {
        Text(viewModel.subtitle)
            .font(.caption)
    }
    
    private func currentAsset(_ displayingAsset: DisplayingAsset) -> some View {
        Group {
            switch displayingAsset.assetType {
            case .photo:
                if let currentImage = displayingAsset.image {
                    Image(uiImage: currentImage)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(8)
                }
            case .video:
                if let currentVideoURL = displayingAsset.videoURL {
                    VideoPlayerWrapper(videoURL: currentVideoURL)
                }
            }
        }
    }
}

struct VideoPlayerWrapper: View {
    let videoURL: URL
    @State private var player: AVPlayer?
    
    var body: some View {
        VideoPlayer(player: player)
            .id(videoURL) // This forces the view to recreate
            .onAppear {
                initializePlayer()
            }
            .onDisappear {
                cleanupPlayer()
            }
            .onChange(of: videoURL) { _, newURL in
                updatePlayer(with: newURL)
            }
    }
    
    private func initializePlayer() {
        player = AVPlayer(url: videoURL)
        player?.play()
    }
    
    private func cleanupPlayer() {
        player?.pause()
        player = nil
    }
    
    private func updatePlayer(with url: URL) {
        // If the URL changes, create a new AVPlayer instance
        player = AVPlayer(url: url)
        player?.play() // Auto-play the new video
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
