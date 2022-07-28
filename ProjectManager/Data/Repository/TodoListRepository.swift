//
//  DefaultTodoListRepository.swift
//  ProjectManager
//
//  Created by 김도연 on 2022/07/06.
//

import Foundation

import RxSwift

final class TodoListRepository {
    private unowned let todoLocalStorage: LocalStorageable
    private let isFirstLogin: Bool
    
    init(todoLocalStorage: LocalStorageable, isFirstLogin: Bool) {
        self.todoLocalStorage = todoLocalStorage
        self.isFirstLogin = isFirstLogin
    }
}

extension TodoListRepository: TodoListRepositorible {
    func create(_ item: Todo) {
        return todoLocalStorage.create(item)
    }
    
    func todosPublisher() -> BehaviorSubject<TodoStorageState> {
        return todoLocalStorage.todosPublisher()
    }
    
    func update(_ item: Todo) {
        return todoLocalStorage.update(item)
    }
    
    func delete(item: Todo) {
        return todoLocalStorage.delete(item)
    }
}
