//
//  RealmStorage.swift
//  ProjectManager
//
//  Created by 김도연 on 2022/07/06.
//

import Foundation

import RxSwift
import RealmSwift

enum StorageError: LocalizedError {
    case createFail
    case updateFail
    case deleteFail
    case readFail
    
    var errorDescription: String? {
        switch self {
        case .createFail:
            return "데이터를 생성하지 못했습니다."
        case .updateFail:
            return "데이터를 업데이트하지 못했습니다."
        case .deleteFail:
            return "데이터를 삭제하지 못했습니다."
        case .readFail:
            return "데이터를 불러오지 못했습니다."
        }
    }
}

protocol LocalStorageable: AnyObject {
    func create(_ item: Todo)
    func todosPublisher() -> BehaviorSubject<TodoStorageState>
    func update(_ item: Todo)
    func delete(_ item: Todo)
}

enum TodoStorageState {
    case success(items: [Todo])
    case failure(error: StorageError)
}

final class RealmStorage: LocalStorageable {
    private let realm = try! Realm()
    private let realmSubject = BehaviorSubject<TodoStorageState>(value: .success(items: []))
    
    init() {
        realmSubject.onNext(.success(items: readAll()))
    }
    
    func create(_ item: Todo) {
        write(.createFail) {
            self.realm.add(self.transferToTodoRealm(with: item))
            self.realmSubject.onNext(.success(items: self.readAll()))
        }
    }
        
    func todosPublisher() -> BehaviorSubject<TodoStorageState> {
        return realmSubject
    }
    
    func update(_ item: Todo) {
        write(.updateFail) {
            self.realm.add(self.transferToTodoRealm(with: item), update: .modified)
            self.realmSubject.onNext(.success(items: self.readAll()))
        }
    }
    
    func delete(_ item: Todo) {
        write(.deleteFail) {
            guard let realmModel = self.realm.object(ofType: TodoRealm.self, forPrimaryKey: item.id) else {
                return
            }
            self.realm.delete(realmModel)
            self.realmSubject.onNext(.success(items: self.readAll()))
        }
    }
    
    private func write(_ realmError: StorageError, _ work: @escaping () -> Void) {
        do {
            try self.realm.write { work() }
        } catch {
            realmSubject.onNext(.failure(error: realmError))
        }
    }
    
    private func readAll() -> [Todo] {
        return realm.objects(TodoRealm.self).map(transferToTodo)
    }
    
    private func transferToTodoRealm(with item: Todo) -> TodoRealm {
        return TodoRealm(
            title: item.title,
            content: item.content,
            deadline: item.deadline,
            processType: item.processType,
            id: item.id
        )
    }
    
    private func transferToTodo(with item: TodoRealm) -> Todo {
        return Todo(
            title: item.title,
            content: item.content,
            deadline: item.deadline,
            processType: item.processType,
            id: item.id
        )
    }
}
