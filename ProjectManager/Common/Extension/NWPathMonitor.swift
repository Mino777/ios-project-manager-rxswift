//
//  NWPathMonitor.swift
//  ProjectManager
//
//  Created by 조민호 on 2022/07/28.
//

import Network

import RxSwift

extension NWPathMonitor: ReactiveCompatible {}

extension Reactive where Base == NWPathMonitor {
  var pathUpdated: Observable<NWPath> {
    return Observable.create { [weak base] observer in
      base?.pathUpdateHandler = observer.onNext
      base?.start(queue: .global(qos: .background))
      return Disposables.create {
        base?.cancel()
      }
    }
  }
}
