//
//  TodoListUseCase.swift
//  ProjectManager
//
//  Created by 김도연 on 2022/07/06.
//

import Foundation

import RxSwift
import RxRelay

protocol TodoListUseCaseable {
    func create(_ item: Todo)
    func todosPublisher() -> BehaviorSubject<TodoStorageState>
    func update(_ item: Todo)
    func delete(item: Todo)
}

final class TodoListUseCase: TodoListUseCaseable {
    private let repository: TodoListRepositorible

    init(repository: TodoListRepositorible) {
        self.repository = repository
    }
    
    func create(_ item: Todo) {
        return repository.create(item)
    }
    
    func todosPublisher() -> BehaviorSubject<TodoStorageState> {
        return repository.todosPublisher()
    }
    
    func update(_ item: Todo) {
        return repository.update(item)
    }
    
    func delete(item: Todo) {
        return repository.delete(item: item)
    }
}
