//
//  TodoViewModel.swift
//  ProjectManager
//
//  Created by 조민호 on 2022/07/13.
//

import Foundation

import RxSwift
import RxRelay

struct MenuType {
    let firstTitle: String
    let secondTitle: String
    let firstProcessType: ProcessType
    let secondProcessType: ProcessType
}

protocol TodoViewModelInput: AnyObject {
    func deleteItem(_ item: Todo)
    func didTapCell(_ item: Todo)
    func didTapFirstContextMenu(_ item: Todo)
    func didTapSecondContextMenu(_ item: Todo)
}

protocol TodoViewModelOutput {
    var state: Observable<TodoStorageState> { get }
    var items: BehaviorRelay<[Todo]> { get }
    var menuType: MenuType { get }
    var headerTitle: String { get }
    
    var errorEvent: PublishSubject<String> { get }
}

protocol TodoViewModelable: TodoViewModelInput, TodoViewModelOutput {}

final class TodoViewModel: TodoViewModelable {
    
    // MARK: - Output
    
    let state: Observable<TodoStorageState>
    let items = BehaviorRelay<[Todo]>(value: [])
    
    lazy var menuType = makeMenuType()
    lazy var headerTitle = makeHeaderTitle()
    let errorEvent = PublishSubject<String>()
    
    private let processType: ProcessType
    private let disposeBag = DisposeBag()
    weak var delegate: TodoViewModelInput?
    
    init(processType: ProcessType, state: Observable<TodoStorageState>) {
        self.processType = processType
        self.state = state
        filteredItems(with: processType, state: state)
    }
    
    private func filteredItems(
        with type: ProcessType,
        state: Observable<TodoStorageState>
    ) {
        state
            .withUnretained(self)
            .flatMap { wself, state -> Observable<[Todo]> in
                switch state {
                case .success(let items):
                    return .just(items)
                case .failure(let error):
                    wself.errorEvent.onNext(error.localizedDescription)
                    return .just([])
                }
            }
            .subscribe { item in
                self.items.accept(item.filter { $0.processType == type })
            }.disposed(by: disposeBag)
    }
    
    private func makeMenuType() -> MenuType {
        switch processType {
        case .todo:
            return MenuType(
                firstTitle: "Move to DOING",
                secondTitle: "Move to DONE",
                firstProcessType: .doing,
                secondProcessType: .done
            )
        case .doing:
            return MenuType(
                firstTitle: "Move to TODO",
                secondTitle: "Move to DONE",
                firstProcessType: .todo,
                secondProcessType: .done
            )
        case .done:
            return MenuType(
                firstTitle: "Move to TODO",
                secondTitle: "Move to DOING",
                firstProcessType: .todo,
                secondProcessType: .doing
            )
        }
    }
    
    private func makeHeaderTitle() -> String {
        switch processType {
        case .todo:
            return "TODO"
        case .doing:
            return "DOING"
        case .done:
            return "DONE"
        }
    }
}

extension TodoViewModel {
    
    // MARK: - Input
    
    func deleteItem(_ item: Todo) {
        delegate?.deleteItem(item)
    }
    
    func didTapCell(_ item: Todo) {
        delegate?.didTapCell(item)
    }
    
    func didTapFirstContextMenu(_ item: Todo) {
        let item = Todo(
            title: item.title,
            content: item.content,
            deadline: item.deadline,
            processType: menuType.firstProcessType,
            id: item.id
        )
        delegate?.didTapFirstContextMenu(item)
    }
    
    func didTapSecondContextMenu(_ item: Todo) {
        let item = Todo(
            title: item.title,
            content: item.content,
            deadline: item.deadline,
            processType: menuType.secondProcessType,
            id: item.id
        )
        delegate?.didTapSecondContextMenu(item)
    }
}
