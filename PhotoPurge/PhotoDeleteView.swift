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
    
    init(photoAssets: [PHAsset]?, navigationPathVM: NavigationPathVM) {
        self._photoDeleteVM = StateObject(wrappedValue: PhotoDeleteVM(photoAssets: photoAssets, navigationPathVM: navigationPathVM))
    }
    
    var body: some View {
        VStack {
            Text(photoDeleteVM.subtitle)
                .font(.title3)
                .padding(.bottom)
            ZStack {
                if let currentPhoto = photoDeleteVM.currentPhoto {
                    Image(uiImage: currentPhoto)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(8)
                    
                    if let nextPhoto = photoDeleteVM.nextPhoto {
                        VStack {
                            HStack {
                                Spacer()
                                Image(uiImage: nextPhoto)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100)
                                    .cornerRadius(8)
                            }
                            Spacer()
                        }
                    }
                }
                else  {
                    VStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                }
            }
            Spacer()
                .frame(height: 32)
            HStack {
                Button {
                    photoDeleteVM.keepPhoto()
                } label: {
                    Image(systemName: "checkmark")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: 40)
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
                        .frame(maxWidth: .infinity, maxHeight: 40)
                        .foregroundColor(.white)
                        .padding(.vertical)
                }
                .background(Color.red)
                .cornerRadius(8)
            }
        }
        .padding(.horizontal)
        .navigationTitle("Photo")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            photoDeleteVM.fetchPhotoInMonth()
        }
    }
    
    
}

#Preview {
    PhotoDeleteView(photoAssets: [], navigationPathVM: .init())
}
