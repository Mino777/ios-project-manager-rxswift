//
//  HistoryStorage.swift
//  ProjectManager
//
//  Created by 김도연 on 2022/07/19.
//

import RxSwift
import RealmSwift

protocol HistoryStorageable: AnyObject {
    func create(_ item: TodoHistory)
    func todoHistoriesPublisher() -> BehaviorSubject<HistoryStorageState>
    func delete(_ item: TodoHistory)
}

enum HistoryStorageState {
    case success(items: [TodoHistory])
    case failure(error: StorageError)
}


final class HistoryStorage: HistoryStorageable {
    private let realm = try! Realm()
    private let realmSubject = BehaviorSubject<HistoryStorageState>(value: .success(items: []))
    
    init() {
        realmSubject.onNext(.success(items: readAll()))
    }
    
    func create(_ item: TodoHistory) {
        return write(.createFail) {
            self.realm.add(self.transferToTodoRealm(with: item))
            self.realmSubject.onNext(.success(items: self.readAll()))
        }
    }
        
    func todoHistoriesPublisher() -> BehaviorSubject<HistoryStorageState> {
        return realmSubject
    }
    
    func delete(_ item: TodoHistory) {
        return write(.deleteFail) {
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
    
    private func readAll() -> [TodoHistory] {
        return realm.objects(TodoHistoryRealm.self).map(transferToTodo).sorted { $0.createdAt > $1.createdAt }
    }
    
    private func transferToTodoRealm(with item: TodoHistory) -> TodoHistoryRealm {
        return TodoHistoryRealm(id: item.id, title: item.title, createdAt: item.createdAt)
    }
    
    private func transferToTodo(with item: TodoHistoryRealm) -> TodoHistory {
        return TodoHistory(title: item.title, createdAt: item.createdAt)
    }
}
