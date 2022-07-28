//
//  AppDIContainer.swift
//  ProjectManager
//
//  Created by 김도연 on 2022/07/06.
//

import Foundation

protocol AppDIContainerable {
    func makeTodoListSceneDIContainer() -> TodoListDIContainer
}

final class AppDIContainer: AppDIContainerable {
    private let todoStorage = RealmStorage()
    private let historyStorage = HistoryStorage()
    
    func makeTodoListSceneDIContainer() -> TodoListDIContainer {
        return TodoListDIContainer(
            dependencies: TodoListDIContainer.Dependencies(
                todoStorage: todoStorage,
                historyStorage: historyStorage
            )
        )
    }
}
