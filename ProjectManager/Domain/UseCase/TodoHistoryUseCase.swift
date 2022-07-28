//
//  TodoHistoryUseCase.swift
//  ProjectManager
//
//  Created by 김도연 on 2022/07/19.
//

import Foundation

import RxSwift

protocol TodoHistoryUseCaseable {
    func create(_ item: TodoHistory)
    func todoHistoriesPublisher() -> BehaviorSubject<HistoryStorageState>
    func delete(item: TodoHistory)
}

final class TodoHistoryUseCase: TodoHistoryUseCaseable {
    private let repository: TodoHistoryRepositorible
    
    init(repository: TodoHistoryRepositorible) {
        self.repository = repository
    }
    
    func create(_ item: TodoHistory) {
        return repository.create(item)
    }
    
    func todoHistoriesPublisher() -> BehaviorSubject<HistoryStorageState> {
        return repository.todoHistoriesPublisher()
    }
    
    func delete(item: TodoHistory) {
        return repository.delete(item: item)
    }
}
