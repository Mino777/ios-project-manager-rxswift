//
//  TodoCreateViewModel.swift
//  ProjectManager
//
//  Created by 김도연 on 2022/07/19.
//

import Foundation

import RxSwift

enum TodoCreateViewModelState {
    case dismissEvent
    case errorEvent(message: String)
}

protocol TodoCreateViewModelInput {
    func didTapCancelButton()
    func didTapDoneButton(_ title: String?, _ content: String?, _ deadline: Date?)
}

protocol TodoCreateViewModelOutput {
    var state: PublishSubject<TodoCreateViewModelState> { get }
}

protocol TodoCreateViewModelable: TodoCreateViewModelInput, TodoCreateViewModelOutput {}

final class TodoCreateViewModel: TodoCreateViewModelable {
    
    // MARK: - Output
        
    let state = PublishSubject<TodoCreateViewModelState>()

    private let todoUseCase: TodoListUseCaseable
    private let historyUseCase: TodoHistoryUseCaseable
    
    init(todoUseCase: TodoListUseCaseable, historyUseCase: TodoHistoryUseCaseable) {
        self.todoUseCase = todoUseCase
        self.historyUseCase = historyUseCase
    }
}

extension TodoCreateViewModel {
    
    // MARK: - Input
    
    func didTapCancelButton() {
        state.onNext(.dismissEvent)
    }
    
    func didTapDoneButton(_ title: String?, _ content: String?, _ deadline: Date?) {
        guard let title = title, let content = content, let deadline = deadline else {
            return
        }
        
        let todoItem = Todo(title: title, content: content, deadline: deadline)
        todoUseCase.create(todoItem)
        
        let historyItem = TodoHistory(title: "[생성] \(todoItem.title)", createdAt: Date())
        historyUseCase.create(historyItem)
        
        state.onNext(.dismissEvent)
    }
}
