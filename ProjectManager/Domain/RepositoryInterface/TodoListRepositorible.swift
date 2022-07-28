//
//  TodoListRepository.swift
//  ProjectManager
//
//  Created by 김도연 on 2022/07/06.
//

import Foundation
import RxSwift

protocol TodoListRepositorible {
    func create(_ item: Todo)
    func todosPublisher() -> BehaviorSubject<TodoStorageState>
    func update(_ item: Todo)
    func delete(item: Todo)
}
