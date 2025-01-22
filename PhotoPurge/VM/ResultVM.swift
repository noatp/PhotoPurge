//
//  ResultVM.swift
//  PhotoPurge
//
//  Created by Toan Pham on 1/21/25.
//

import Combine

class ResultVM: ObservableObject {
    @Published var deleteResult: DeleteResult?

    private let assetService: AssetService
    private var subscriptions: [AnyCancellable] = []

    init(assetService: AssetService) {
        self.assetService = assetService
        self.addSubscription()
    }
    
    init(deleteResult: DeleteResult) {
        self.deleteResult = deleteResult
        self.assetService = .init()
    }
    
    private func addSubscription() {
        assetService.$deleteResult.sink { deleteResult in
            guard let deleteResult else { return }
            self.deleteResult = deleteResult
        }
        .store(in: &subscriptions)
    }
}

extension Dependency.ViewModels {
    func resultVM() -> ResultVM {
        return ResultVM(assetService: services.assetService)
    }
}

