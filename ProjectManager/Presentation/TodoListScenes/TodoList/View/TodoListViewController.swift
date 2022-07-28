//
//  TodoListViewController.swift
//  ProjectManager
//
//  Created by 김도연 on 2022/07/06.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit

final class TodoListViewController: UIViewController, Alertable {
    private unowned let dependency: TodoListDIContainer
    weak var coordinator: TodoListViewCoordinator?
    private lazy var todoListView = dependency.makeTodoListView()
    private let viewModel: TodoListViewModelable
    
    private let disposeBag = DisposeBag()
    
    init(viewModel: TodoListViewModelable, dependency: TodoListDIContainer) {
        self.viewModel = viewModel
        self.dependency = dependency
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        viewModel.viewDidLoad()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        addSubviews()
        setupConstraint()
        setupView()
        bind()
    }
    
    private func bind() {
        viewModel.state
            .withUnretained(self)
            .subscribe { wself, state in
                switch state {
                case .viewTitleEvent(let title):
                    wself.title = title
                case .errorEvent(let message):
                    wself.showErrorAlertWithConfirmButton(message)
                case .showEditViewEvent(let item):
                    wself.coordinator?.showEditViewController(item)
                case .showHistoryViewEvent:
                    guard let sourceView = wself.navigationItem.leftBarButtonItem else {
                        return
                    }
                    wself.coordinator?.showHistoryViewController(sourceView: sourceView)
                case .showCreateViewEvent:
                    wself.coordinator?.showCreateViewController()
                }
            }.disposed(by: disposeBag)
        
        
        viewModel.networkMonitor.rx.pathUpdated
            .map { $0.status == .satisfied
              ? UIImage(systemName: "wifi")
              : UIImage(systemName: "wifi.slash")
            }
            .bind(to: todoListView.networkStatusImageView.rx.image)
            .disposed(by: disposeBag)
    }
    
    private func addSubviews() {
        view.addSubview(todoListView)
    }
    
    private func setupConstraint() {
        todoListView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func setupView() {
        view.backgroundColor = .systemBackground
        
        let showHistory = UIAction { [weak self] _ in
            self?.viewModel.didTapHistoryButton()
        }
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "History", image: nil, primaryAction: showHistory)
        
        let addAction = UIAction { [weak self] _ in
            self?.viewModel.didTapAddButton()
        }

        navigationItem.rightBarButtonItem = UIBarButtonItem(systemItem: .add, primaryAction: addAction)
    }
}
