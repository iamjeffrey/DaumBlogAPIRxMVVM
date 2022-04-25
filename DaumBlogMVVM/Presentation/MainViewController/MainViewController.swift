//
//  MainViewController.swift
//  RxSwiftPractice2
//
//  Created by Seonghwan on 2022/02/03.
//

import UIKit
import RxSwift
import RxCocoa

class MainViewController: UIViewController {
    let disposeBag = DisposeBag()
    
    let listView = BlogListView()
    let searchBar = SearchBar()
    
    // Alert action
    //let alertActionTapped = PublishRelay<AlertAction>()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
       // bind()
        attribute()
        layout()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(_ viewModel: MainViewModel) {
        //header, searchbar bind viewmodel
        listView.bind(viewModel.blogListViewModel)
        searchBar.bind(viewModel.searchBarViewModel)
        
        
        //Network Logic은 ViewModel로
        /*
         enum Result<Success, Failure>
             case success(Success)
             case failure(Failure)
         */
        /*
        //Single<Result<DKBlog, SearchNetworkError>>
        let blogResult = searchBar.shouldLoadResult
            .flatMapLatest {
                SearchBlogNetwork().searchBlog(query: $0)
            }
            .share() //Stream 공유
        
        //Stream 분리
        let blogValue = blogResult.compactMap { data -> DKBlog? in
            guard case .success(let value) = data else {
                return nil
            }
            return value //Observable<DKBlog>
        }
        
        let blogError = blogResult.compactMap { data -> String? in
            guard case .failure(let error) = data else {
                return nil
            }
            return error.localizedDescription //Observable<String>으로 리턴
        }
        
        //네트워크를 통해 가져온 값을 CellData로 변환
        let cellData = blogValue.map { blog -> [BlogListCellData] in
            return blog.documents.map {
                let thumnailURL = URL(string: $0.thumbnail ?? "")
                return BlogListCellData(thumbnailURL: thumnailURL,
                                        name: $0.name,
                                        title: $0.title,
                                        datetime: $0.datetime)
            }
        }
        
        //FilterView를 선택했을 때 나오는 alertsheet를 선택했을 때 type Sorting
        //확인, 취소 action은 무시
        let sortedType = alertActionTapped
            .filter {
                switch $0 {
                case .title, .datetime: return true
                default: return false
                }
            }
            .startWith(.title) //처음 나타날 테이블뷰 데이터는 title
        
        //MainViewController -> ListView에 data 전달
        Observable.combineLatest(sortedType, cellData)
        { type, data -> [BlogListCellData] in
            switch type {
            case .title:
                return data.sorted { $0.title ?? "" < $1.title ?? "" }
            case .datetime:
                return data.sorted { $0.datetime ?? Date() > $1.datetime ?? Date() }
            default: return data
            }
        }
        .bind(to: listView.cellData) //PublishSubject<[BlogListCellData]>() //ListView data
        .disposed(by: disposeBag)
         
        
        let alertForErrorMessage = blogError
            .map { _ -> Alert in
                return (
                    title: "Alert",
                    message: "예상치 못한 오류가 발생했습니다. 잠시 후 다시 시도해주세요.",
                    actions: [.confirm],
                    style: .alert
                )
            }
        
        //sort button을 누르면 만든 Alert로 변경
        let alertSheetForSorting = listView.headerView.sortButtonTapped
            .map { _ -> Alert in
                return (title: nil,
                        message: nil,
                        actions: [.title, .datetime, .cancel],
                        style: .actionSheet)
            }
         */
        
        //Alert 메시지를 데이터 필터링 또는 오류 메시지도 같이 처리하기 위해 merge
        //Observable
        //    .merge(alertForErrorMessage, alertSheetForSorting)
        //.asSignal(onErrorSignalWith: .empty())
        viewModel.shouldPresentAlert
        //alertSheetForSorting.asSignal(onErrorSignalWith: .empty())
            .flatMapLatest { alert -> Signal<AlertAction> in
                let alertViewController = UIAlertController(title: alert.title,
                                                            message: alert.message,
                                                            preferredStyle: alert.style)
                return self.presentAlertController(
                    alertViewController, actions: alert.actions
                )
            }
            .emit(to: viewModel.alertActionTapped)
            .disposed(by: disposeBag)
        
    }
    
    private func attribute() {
        title = "다음 블로그 검색"
        view.backgroundColor = .white
    }
    
    private func layout() {
        [searchBar, listView].forEach { view.addSubview($0) }
        
        searchBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
        }
        
        listView.snp.makeConstraints {
            $0.top.equalTo(searchBar.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    


}

//Bottom Alert
extension MainViewController {
    typealias Alert = (title: String?, message: String?, actions: [AlertAction], style: UIAlertController.Style)
    
    enum AlertAction: AlertActionConvertible {
        case title, datetime, cancel
        case confirm
        var title: String {
            switch self {
            case .title:
                return "Title"
            case .datetime:
                return "Datetime"
            case .cancel:
                return "취소"
            case .confirm:
                return "확인"
            }
        }
        
        var style: UIAlertAction.Style {
            switch self {
            case .title, .datetime:
                return .default
            case .cancel, .confirm:
                return .cancel
            }
        }
    }
    
    //AlertController 생성
    func presentAlertController<Action: AlertActionConvertible>(
                _ alertController: UIAlertController, actions: [Action]
            ) -> Signal<Action> {
                if actions.isEmpty { return .empty() }
                return Observable
                    .create { [weak self] observer in
                        guard let `self` = self else { return Disposables.create() }
                        for action in actions {
                            alertController.addAction(
                                UIAlertAction(
                                    title: action.title,
                                    style: action.style,
                                    handler: { _ in
                                        observer.onNext(action)
                                        observer.onCompleted()
                                    }
                                )
                            )
                        } //end of for
                        self.present(alertController, animated: true, completion: nil)
                        return Disposables.create {
                            alertController.dismiss(animated: true, completion: nil)
                        }
                    }
                    .asSignal(onErrorSignalWith: .empty())
    }
}

