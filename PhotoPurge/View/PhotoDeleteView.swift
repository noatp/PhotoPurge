//
//  ContentView.swift
//  PhotoPurge
//
//  Created by Toan Pham on 1/10/25.
//

import SwiftUI
import Photos
import AVKit

struct PhotoDeleteView: View {   // Use generics to specify the protocol type
    @StateObject var photoDeleteVM: PhotoDeleteVM
    @State private var player: AVPlayer?
    
    init(
        assets: [PHAsset]?,
        navigationPathVM: NavigationPathVM,
        mockPhotoDeleteVM: PhotoDeleteVM? = nil
    ) {
        guard let mockPhotoDeleteVM = mockPhotoDeleteVM else {
            self._photoDeleteVM = StateObject(wrappedValue: PhotoDeleteVM(assets: assets, navigationPathVM: navigationPathVM))
            return
        }
        self._photoDeleteVM = StateObject(wrappedValue: mockPhotoDeleteVM)
        
    }
    
    var body: some View {
        ZStack {
            if let currentDisplayingAsset = photoDeleteVM.currentDisplayingAsset {
                VStack {
                    subtitle
                    Spacer()
                    currentAsset(currentDisplayingAsset)
                    Spacer(minLength: 32)
                    keepDeleteButtonBar
                }
                
                VStack {
                    Spacer()
                        .frame(height: 32)
                    HStack (alignment: .top) {
                        if photoDeleteVM.shouldShowUndoButton {
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
        .padding(.horizontal)
        .navigationTitle("Photo")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            photoDeleteVM.fetchNewPhotos()
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
            photoDeleteVM.undoLatestAction()
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
                photoDeleteVM.keepPhoto()
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
                photoDeleteVM.deletePhoto()
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
            if let nextImageUIImage = photoDeleteVM.nextImage {
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
    
    private func nextAsset(_ displayingAsset: DisplayingAsset) -> some View {
        Group {
            switch displayingAsset.assetType {
            case .photo:
                if let nextImage = displayingAsset.image {
                    Image(uiImage: nextImage)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(8)
                }
            case .video:
                if let currentVideoURL = displayingAsset.videoURL {
                    let avPlayer = AVPlayer(url: currentVideoURL)
                    VideoPlayer(player: avPlayer)
                        .cornerRadius(8)
                }
            }
        }
    }
    
    var subtitle: some View {
        Text(photoDeleteVM.subtitle)
            .font(.title3)
            .padding(.bottom)
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
                    VideoPlayer(player: player)
                        .cornerRadius(8)
                        .onAppear {
                            // Ensure player is initialized and ready
                            self.player = AVPlayer(url: currentVideoURL)
                            self.player?.play() // Start playback
                        }
                        .onDisappear {
                            self.player?.pause() // Pause when leaving the view
                        }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        PhotoDeleteView(
            assets: [],
            navigationPathVM: .init(),
            mockPhotoDeleteVM: .init(
                assets: [],
                navigationPathVM: NavigationPathVM(),
                currentDisplayingAsset: .init(assetType: .photo, image: .init(named: "test1")),
                nextImage: .init(named: "test1"),
                subtitle: "2 of 3",
                shouldShowUndoButton: true
            )
        )
    }
}

#Preview {
    NavigationStack {
        PhotoDeleteView(
            assets: [],
            navigationPathVM: .init(),
            mockPhotoDeleteVM: .init(
                assets: [],
                navigationPathVM: NavigationPathVM(),
                currentDisplayingAsset: .init(assetType: .video, videoURL: .init(string: "https://www.youtube.com/shorts/aeTsXBCZUsI")),
                nextImage: .init(named: "test2"),
                subtitle: "2 of 3",
                shouldShowUndoButton: true
            )
        )
    }
}


