//
//  FirebaseService.swift
//  Color_Generator
//
//  Created by Akshat Dutt Kaushik on 30/07/25.
//

import FirebaseFirestore
import Combine

class FirebaseService {
    static let shared = FirebaseService()
    private let db = Firestore.firestore()
    private let collectionName = "userColors"
    
    private init() {}
    
    func syncColor(_ item: Item) -> AnyPublisher<Void, Error> {
        let colorData: [String: Any] = [
            "hexCode": item.hexCode,
            "timestamp": item.timestamp,
            "isSynced": true
        ]
        
        return Future<Void, Error> { promise in
            self.db.collection(self.collectionName).document(item.hexCode).setData(colorData) { error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(()))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func syncAllUnsyncedItems(items: [Item]) -> AnyPublisher<Void, Error> {
        let unsyncedItems = items.filter { !$0.isSynced }
        
        return Publishers.Sequence(sequence: unsyncedItems)
            .flatMap { item in
                self.syncColor(item)
            }
            .collect()
            .map { _ in () }
            .eraseToAnyPublisher()
    }
}
