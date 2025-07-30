//
//  SyncManager.swift
//  Color_Generator
//
//  Created by Akshat Dutt Kaushik on 30/07/25.
//

import Combine
import Foundation
import SwiftData

class SyncManager {
    static let shared = SyncManager()
    private let firebaseService = FirebaseService.shared
    private let networkMonitor = NetworkMonitor.shared
    private var cancellables = Set<AnyCancellable>()
    
    enum SyncStatus {
        case success(message: String)
        case failure(error: Error)
        case offlineSavedLocally
    }
    
    typealias SyncHandler = (SyncStatus) -> Void
    
    private init() {
        setupNetworkObserver()
    }
    
    private func setupNetworkObserver() {
        networkMonitor.$isConnected
            .removeDuplicates()
            .sink { [weak self] isConnected in
                if isConnected {
                    self?.syncPendingItems()
                }
            }
            .store(in: &cancellables)
    }
    
    func syncItem(_ item: Item, context: ModelContext, handler: @escaping SyncHandler) {
        guard !item.isSynced else { return }
        
        if networkMonitor.isConnected {
            firebaseService.syncColor(item)
                .receive(on: DispatchQueue.main)
                .sink(
                    receiveCompletion: { completion in
                        if case .failure(let error) = completion {
                            handler(.failure(error: error))
                        }
                    },
                    receiveValue: { _ in
                        item.isSynced = true
                        try? context.save()
                        let message = UserDefaults.standard.bool(forKey: "hasSyncedBefore") ?
                            "Synced to cloud!" : "First sync complete!"
                        handler(.success(message: message))
                        UserDefaults.standard.set(true, forKey: "hasSyncedBefore")
                    }
                )
                .store(in: &cancellables)
        } else {
            handler(.offlineSavedLocally)
        }
    }
    
    func syncPendingItems() {
    }
}
