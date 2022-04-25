//
//  MainViewModel.swift
//  DaumBlogMVVM
//
//  Created by Seonghwan on 2022/02/04.
//

import RxSwift
import RxCocoa

class MainViewModel {
    let disposeBag = DisposeBag()
    
    //MainViewController가 BlogListView와 SearchBar 뷰를
    //가지고 있기 때문에 MainViewModel도 각 Model이 필요
    let searchBarViewModel = SearchBarViewModel()
    let blogListViewModel = BlogListViewModel()
    
    // Alert action
    let alertActionTapped = PublishRelay<MainViewController.AlertAction>()
    
    let shouldPresentAlert: Signal<MainViewController.Alert>
    
    init(model: MainModel = MainModel()) {
        
        /*
         enum Result<Success, Failure>
             case success(Success)
             case failure(Failure)
         */
        //Single<Result<DKBlog, SearchNetworkError>>
        let blogResult = //searchBar.shouldLoadResult
        searchBarViewModel.shouldLoadResult
            /*
            .flatMapLatest {
                //SearchBlogNetwork().searchBlog(query: $0)
                model.searchBlog($0)
            }
             */
            //flatMapLatest와
            //model.searchBlog 인자가 동일하기 때문에 축약
            .flatMapLatest(model.searchBlog)
            .share() //Stream 공유
        
        //blogResult type -> Result<DKBlog, SearchNetworkError>
        //Stream 분리
        let blogValue = blogResult.compactMap(model.getBlogValue)
        /*
        { data -> DKBlog? in
            guard case .success(let value) = data else {
                return nil
            }
            return value //Observable<DKBlog>
        }
        */
        
        //blogResult type -> Result<DKBlog, SearchNetworkError>
        let blogError = blogResult.compactMap(model.getBlogError)
        /*{ data -> String? in
            guard case .failure(let error) = data else {
                return nil
            }
            return error.localizedDescription //Observable<String>으로 리턴
        }
        */
        
        //----------------------------
        //ViewModel끼리 네트워크 처리 : model로 refactoring
        
        //네트워크를 통해 가져온 값을 CellData로 변환
        let cellData = blogValue.map(model.getBlogListCellData)
        /*
        { blog -> [BlogListCellData] in
            return blog.documents.map {
                let thumnailURL = URL(string: $0.thumbnail ?? "")
                return BlogListCellData(thumbnailURL: thumnailURL,
                                        name: $0.name,
                                        title: $0.title,
                                        datetime: $0.datetime)
            }
        }
        */
        
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
        //combineLatest(sortedType, cellData)(model.sort) 알아보기 어려움기 아래처럼 resultSelector 사용
        Observable
            .combineLatest(
                sortedType,
                cellData,
                resultSelector: model.sort //결과
            )
        /*
         //Sort -> model로
            .combineLatest(sortedType, cellData)
        { type, data -> [BlogListCellData] in
            switch type {
            case .title:
                return data.sorted { $0.title ?? "" < $1.title ?? "" }
            case .datetime:
                return data.sorted { $0.datetime ?? Date() > $1.datetime ?? Date() }
            default: return data
            }
        }
         */
        .bind(to: blogListViewModel.blogCellData) //PublishSubject<[BlogListCellData]>() //ListView data
        .disposed(by: disposeBag)
        
        let alertForErrorMessage = blogError
            .map { _ -> MainViewController.Alert in
                return (
                    title: "Alert",
                    message: "예상치 못한 오류가 발생했습니다. 잠시 후 다시 시도해주세요.",
                    actions: [.confirm],
                    style: .alert
                )
            }
        
        //sort button을 누르면 만든 Alert로 변경
        let alertSheetForSorting = //listView.headerView.sortButtonTapped
        blogListViewModel.filterViewModel.sortButtonTapped
            .map { _ -> MainViewController.Alert in
                return (title: nil,
                        message: nil,
                        actions: [.title, .datetime, .cancel],
                        style: .actionSheet)
            }
        
        
        //Alert 메시지를 데이터 필터링 또는 오류 메시지도 같이 처리하기 위해 merge
        self.shouldPresentAlert =  Observable
            .merge(alertForErrorMessage, alertSheetForSorting)
        .asSignal(onErrorSignalWith: .empty())
        
    } //
}
