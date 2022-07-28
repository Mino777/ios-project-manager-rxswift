//
//  TodoHistoryRepository.swift
//  ProjectManager
//
//  Created by 김도연 on 2022/07/19.
//

import Foundation

import RxSwift

final class TodoHistoryRepository {
    private unowned let storage: HistoryStorageable
    
    init(storage: HistoryStorageable) {
        self.storage = storage
    }
}

extension TodoHistoryRepository: TodoHistoryRepositorible {
    func create(_ item: TodoHistory) {
        return storage.create(item)
    }
    
    func todoHistoriesPublisher() -> BehaviorSubject<HistoryStorageState> {
        return storage.todoHistoriesPublisher()
    }
    
    func delete(item: TodoHistory) {
        return storage.delete(item)
    }
}
