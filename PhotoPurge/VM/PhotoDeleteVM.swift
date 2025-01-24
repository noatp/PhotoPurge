//
//  LandingScreenVM.swift
//  PhotoPurge
//
//  Created by Toan Pham on 1/10/25.
//

import Foundation
import Photos
import UIKit
import Combine

enum LatestAction{
    case delete
    case keep
}

class PhotoDeleteVM: ObservableObject {
    @Published var assetsGroupedByMonth: [Date: [PHAsset]]?
    @Published var currentDisplayingAsset: DisplayingAsset?
    @Published var nextImage: UIImage?
    @Published var shouldShowUndoButton: Bool = false
    @Published var shouldNavigateToResult: Bool = false
    @Published var shouldDisableActionButtons: Bool = false
    @Published var selectedMonth: Date?
    @Published var errorMessage: String?
    @Published var subtitle: String = ""
    @Published var title: String = ""
    @Published var assetsToDelete: [PHAsset] = []
    
    private var currentAssetIndex = -1
    private var assets: [PHAsset]?
    private var isDeletingPhotos: Bool = false
    private var pastActions: [LatestAction] = [] {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let self, let assets else {
                    return
                }
                shouldShowUndoButton = !pastActions.isEmpty
                shouldDisableActionButtons = pastActions.count >= assets.count
            }
        }
    }
    
    private let assetService: AssetService
    private var subscriptions: [AnyCancellable] = []
    
    init(
        assetService: AssetService
    ) {
        self.assetService = assetService
        self.addSubscription()
        print("PhotoDeleteVM init")
    }
    
    init(
        assetsGroupedByMonth: [Date: [PHAsset]]?,
        currentDisplayingAsset: DisplayingAsset?,
        nextImage: UIImage?,
        shouldShowUndoButton: Bool,
        shouldNavigateToResult: Bool,
        shouldDisableActionButtons: Bool,
        selectedMonth: Date?,
        errorMessage: String?,
        subtitle: String,
        title: String
    ) {
        self.assetsGroupedByMonth = assetsGroupedByMonth
        self.currentDisplayingAsset = currentDisplayingAsset
        self.nextImage = nextImage
        self.shouldShowUndoButton = shouldShowUndoButton
        self.shouldNavigateToResult = shouldNavigateToResult
        self.shouldDisableActionButtons = shouldDisableActionButtons
        self.selectedMonth = selectedMonth
        self.errorMessage = errorMessage
        self.subtitle = subtitle
        self.title = title

        self.assetService = .init()
    }
    
    private func addSubscription() {
        assetService.$assetsGroupedByMonth.sink { [weak self] assetsGroupedByMonth in
            if let assetsGroupedByMonth = assetsGroupedByMonth {
                self?.assetsGroupedByMonth = assetsGroupedByMonth
                self?.initMonthAsset()
            }
        }
        .store(in: &subscriptions)
    }
    
#if DEBUG
    deinit {
        print("PhotoDeleteVM deinit")
    }
#endif
        
    func keepPhoto() {
        guard let assets, pastActions.count < assets.count else { return }
        pushLastestAction(.keep)
        fetchNewPhotos()
    }
    
    func deletePhoto() {
        guard let assets, pastActions.count < assets.count else { return }
        pushLastestAction(.delete)
        assetsToDelete.append(assets[currentAssetIndex])
        fetchNewPhotos()
    }
    
    func fetchAssets() {
        assetService.fetchAssets()
    }
    
    func selectMonth(date: Date) {
        guard let assetsGroupedByMonth = assetsGroupedByMonth else { return }
        
        guard let assets = assetsGroupedByMonth[date] else {
            return
        }
               
        resetForNewMonth()
        self.selectedMonth = date
        self.assets = assets
        self.title = Util.getMonthString(from: date)
        fetchNewPhotos()
    }
    
    func fetchNewPhotos() {
        currentAssetIndex += 1
        if isIndexValid(currentAssetIndex){
            fetchAssetAtIndex(currentAssetIndex)
            fetchNextAsset(currentIndex: currentAssetIndex)
        }
    }
    
    func fetchPreviousPhotos() {
        currentAssetIndex -= 1
        fetchAssetAtIndex(currentAssetIndex)
        fetchNextAsset(currentIndex: currentAssetIndex)
    }
    
    func resetForNewMonth() {
        currentAssetIndex = -1
        assetsToDelete = []
        pastActions = []
        errorMessage = nil
    }
    
    func resetErrorMessage() {
        errorMessage = nil
    }
    
    func undoLatestAction() {
        guard !pastActions.isEmpty else { return }
        let latestAction = pastActions.removeLast()
        switch latestAction {
        case .delete:
            undoDeletePhoto()
        case .keep:
            backtrack()
        }
    }
    
    func deletePhotoFromDevice() {
        guard !isDeletingPhotos else { return }
        isDeletingPhotos = true
        assetService.deleteAssets(assetsToDelete) { result in
            switch result {
            case .success():
                DispatchQueue.main.async { [weak self] in
                    self?.shouldNavigateToResult = true
                    self?.isDeletingPhotos = false
                }
            case .failure(let error):
                DispatchQueue.main.async { [weak self] in
                    self?.errorMessage = error.localizedDescription
                    self?.isDeletingPhotos = false
                }
            }
        }
    }

    
    private func initMonthAsset() {
        guard let assetsGroupedByMonth else { return }
        
        guard let selectedMonth else {
            guard let oldestMonth = assetsGroupedByMonth.keys.sorted().first else { return }
            selectMonth(date: oldestMonth)
            return
        }
        
        guard assetsGroupedByMonth[selectedMonth] != nil else {
            guard let closestKey = closestKey(to: selectedMonth, in: assetsGroupedByMonth) else {
                return
            }
            selectMonth(date: closestKey)
            return
        }
        
        selectMonth(date: selectedMonth)
    }
    
    private func closestKey(to targetDate: Date, in dictionary: [Date: Any]) -> Date? {
        guard !dictionary.isEmpty else { return nil }

        let validKeys = dictionary.keys.filter { $0 > targetDate }

        return validKeys.min(by: { abs($0.timeIntervalSince(targetDate)) < abs($1.timeIntervalSince(targetDate)) })
    }
    
    private func pushLastestAction(_ latestAction: LatestAction) {
        guard let assets, pastActions.count < assets.count else { return }
        pastActions.append(latestAction)
    }
    
    private func fetchNextAsset(currentIndex: Int) {
        guard let assets, isNextIndexValid(currentIndex: currentIndex) else {
            DispatchQueue.main.async {
                self.nextImage = nil
            }
            return
        }

        let nextAsset = assets[currentIndex + 1]
        assetService.fetchPhotoForAsset(nextAsset) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let image):
                DispatchQueue.main.async {
                    self.nextImage = image
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
            }
            
        }
    }
    
    private func fetchAssetAtIndex(_ index: Int) {
        guard isIndexValid(index), let assets else { return }
        setSubtitle(withIndex: index)
        
        let asset = assets[index]
        
        if asset.mediaType == .image {
            assetService.fetchPhotoForAsset(asset) { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(let image):
                    DispatchQueue.main.async {
                        self.currentDisplayingAsset = .init(assetType: .photo, image: image)
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        self.errorMessage = error.localizedDescription
                    }
                }
                
                
            }
        }
        else if asset.mediaType == .video {
            assetService.fetchVideoForAsset(asset) { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(let video):
                    DispatchQueue.main.async {
                        self.currentDisplayingAsset = .init(assetType: .video, video: video)
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        self.errorMessage = error.localizedDescription
                    }
                }
                
            }
        }
        
        
    }
    
    private func setSubtitle(withIndex index: Int) {
        guard let assets else { return }
        
        subtitle = "\(index + 1) of \(assets.count)"
    }
    
    private func isNextIndexValid(currentIndex index: Int) -> Bool {
        return isIndexValid(index + 1)
    }
    
    private func isIndexValid(_ index: Int) -> Bool {
        guard let assets else { return false }
        return index >= 0 && index < assets.count
    }
    
    private func undoDeletePhoto() {
        backtrack()
        if assetsToDelete.count > 0 {
            assetsToDelete.removeLast()
        }
    }
    
    private func backtrack() {
        fetchPreviousPhotos()
    }
}

extension Dependency.ViewModels {
    func photoDeleteVM() -> PhotoDeleteVM {
        return PhotoDeleteVM(assetService: services.assetService)
    }
}
