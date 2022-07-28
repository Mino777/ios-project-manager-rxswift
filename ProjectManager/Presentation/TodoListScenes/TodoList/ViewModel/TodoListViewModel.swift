//
//  TodoListViewModel.swift
//  ProjectManager
//
//  Created by 김도연 on 2022/07/06.
//

import Foundation
import RxSwift
import Network

enum TodoListViewModelState {
    case viewTitleEvent(title: String)
    case errorEvent(message: String)
    case showEditViewEvent(item: Todo)
    case showHistoryViewEvent
    case showCreateViewEvent
}

protocol TodoListViewModelInput {
    func viewDidLoad()
    func didTapAddButton()
    func didTapHistoryButton()
}

protocol TodoListViewModelOutput {
    var networkMonitor: NWPathMonitor { get }

    var state: PublishSubject<TodoListViewModelState> { get }
}

protocol TodoListViewModelable: TodoListViewModelInput, TodoListViewModelOutput {}

final class TodoListViewModel: TodoListViewModelable {
    
    // MARK: - Output
    
    let networkMonitor = NWPathMonitor()
    
    let todoStorageState: Observable<TodoStorageState>
    let state = PublishSubject<TodoListViewModelState>()
    
    private let todoUseCase: TodoListUseCaseable
    private let historyUseCase: TodoHistoryUseCaseable
    
    init(todoUseCase: TodoListUseCaseable, historyUseCase: TodoHistoryUseCaseable) {
        self.todoUseCase = todoUseCase
        self.historyUseCase = historyUseCase
        self.todoStorageState = todoUseCase.todosPublisher()
    }
}

extension TodoListViewModel {
    
    // MARK: - Input
    
    func viewDidLoad() {
        state.onNext(.viewTitleEvent(title: "Project Manager"))
    }
    
    func didTapAddButton() {
        state.onNext(.showCreateViewEvent)
    }
    
    func didTapHistoryButton() {
        state.onNext(.showHistoryViewEvent)
    }
}

extension TodoListViewModel: TodoViewModelInput {
    func deleteItem(_ item: Todo) {
        todoUseCase.delete(item: item)
        
        let historyItem = TodoHistory(title: "[삭제] \(item.title)", createdAt: Date())
        historyUseCase.create(historyItem)
    }
    
    func didTapCell(_ item: Todo) {
        state.onNext(.showEditViewEvent(item: item))
    }
    
    func didTapFirstContextMenu(_ item: Todo) {
        todoUseCase.update(item)
        
        let historyItem = TodoHistory(title: "[수정] \(item.title)", createdAt: Date())
        historyUseCase.create(historyItem)
    }
    
    func didTapSecondContextMenu(_ item: Todo) {
        todoUseCase.update(item)
        
        let historyItem = TodoHistory(title: "[수정] \(item.title)", createdAt: Date())
        historyUseCase.create(historyItem)
    }
}
