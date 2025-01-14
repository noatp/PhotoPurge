//
//  ContentView.swift
//  PhotoPurge
//
//  Created by Toan Pham on 1/10/25.
//

import SwiftUI
import Photos

struct PhotoDeleteView: View {   // Use generics to specify the protocol type
    @StateObject var photoDeleteVM: PhotoDeleteVM
    
    init(
        photoAssets: [PHAsset]?,
        navigationPathVM: NavigationPathVM,
        mockPhotoDeleteVM: PhotoDeleteVM? = nil
    ) {
        guard let mockPhotoDeleteVM = mockPhotoDeleteVM else {
            self._photoDeleteVM = StateObject(wrappedValue: PhotoDeleteVM(photoAssets: photoAssets, navigationPathVM: navigationPathVM))
            return
        }
        self._photoDeleteVM = StateObject(wrappedValue: mockPhotoDeleteVM)
        
    }
    
    var body: some View {
        ZStack {
            if let currentPhoto = photoDeleteVM.currentPhoto {
                VStack {
                    subtitle
                    Spacer()
                    Image(uiImage: currentPhoto)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(8)
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
                        nextPhotoImage
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
    
    var nextPhotoImage: some View {
        Group {
            if let nextPhoto = photoDeleteVM.nextPhoto {
                Image(uiImage: nextPhoto)
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
        Text(photoDeleteVM.subtitle)
            .font(.title3)
            .padding(.bottom)
    }
}

#Preview {
    NavigationStack {
        PhotoDeleteView(
            photoAssets: [],
            navigationPathVM: .init(),
            mockPhotoDeleteVM: .init(
                photoAssets: [],
                navigationPathVM: .init(),
                currentPhoto: .init(named: "test1"),
                nextPhoto: .init(named: "test2"),
                subtitle: "0 of 2",
                shouldShowUndoButton: true
            )
        )
    }
}

#Preview {
    NavigationStack {
        PhotoDeleteView(
            photoAssets: [],
            navigationPathVM: .init(),
            mockPhotoDeleteVM: .init(
                photoAssets: [],
                navigationPathVM: .init(),
                currentPhoto: nil,
                nextPhoto: .init(systemName: "tray.2.fill"),
                subtitle: "0 of 2",
                shouldShowUndoButton: true
            )
        )
    }
}
