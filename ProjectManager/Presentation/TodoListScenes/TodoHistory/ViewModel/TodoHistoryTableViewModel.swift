//
//  TodoHistoryTableViewModel.swift
//  ProjectManager
//
//  Created by 김도연 on 2022/07/19.
//

import Foundation

import RxSwift
import RxRelay

protocol TodoHistoryTableViewModelInput {
    // empty
}

protocol TodoHistoryTableViewModelOutput {
    var items: BehaviorRelay<[TodoHistory]> { get }
}

protocol TodoHistoryTableViewModelable: TodoHistoryTableViewModelInput, TodoHistoryTableViewModelOutput {}

final class TodoHistoryTableViewModel: TodoHistoryTableViewModelable {
    
    // MARK: - Output
    
    let items = BehaviorRelay<[TodoHistory]>(value: [])
    
    private let historyUseCase: TodoHistoryUseCaseable
    private let disposeBag = DisposeBag()

    init(historyUseCase: TodoHistoryUseCaseable) {
        self.historyUseCase = historyUseCase
        self.setData()
    }
    
    private func setData() {
        historyUseCase.todoHistoriesPublisher()
            .withUnretained(self)
            .flatMap { wself, state -> Observable<[TodoHistory]> in
                switch state {
                case .success(let items):
                    return .just(items)
                case .failure(_):
                    return .just([])
                }
            }
            .subscribe { items in
                self.items.accept(items)
            }.disposed(by: disposeBag)
    }
}
