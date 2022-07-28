//
//  TodoHistoryRepositorible.swift
//  ProjectManager
//
//  Created by 김도연 on 2022/07/19.
//

import Foundation
import RxSwift

protocol TodoHistoryRepositorible {
    func create(_ item: TodoHistory)
    func todoHistoriesPublisher() -> BehaviorSubject<HistoryStorageState>
    func delete(item: TodoHistory)
}
