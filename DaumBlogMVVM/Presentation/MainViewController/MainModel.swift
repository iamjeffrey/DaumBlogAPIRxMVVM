//
//  MainModel.swift
//  DaumBlogMVVM
//
//  Created by Seonghwan on 2022/02/04.
//

import RxSwift
import RxCocoa

//MainViewModel의 구체적인 비지니스 모델은 Model 분리
struct MainModel {
    //네트워크 처리는 ViewModel에서 model로
    let newtotk = SearchBlogNetwork()
    
    func searchBlog(_ query: String) -> Single<Result<DKBlog, SearchNetworkError>> {
        return newtotk.searchBlog(query: query)
    }
    
    func getBlogValue(_ result: Result<DKBlog, SearchNetworkError>) -> DKBlog? {
        guard case .success(let value) = result else {
            return nil
        }
        return value
    }
    
    func getBlogError(_ result: Result<DKBlog, SearchNetworkError>) -> String? {
        guard case .failure(let error) = result else {
            return nil
        }
        return error.localizedDescription //Observable<String>으로 리턴
    }
    
    
    func getBlogListCellData(_ value: DKBlog) -> [BlogListCellData] {
        return value.documents.map {
            let thumnailURL = URL(string: $0.thumbnail ?? "")
            return BlogListCellData(thumbnailURL: thumnailURL,
                                    name: $0.name,
                                    title: $0.title,
                                    datetime: $0.datetime)
        }
    }
    
    //ResultSelector
    func sort(by type: MainViewController.AlertAction, of data: [BlogListCellData]) -> [BlogListCellData] {
        
        switch type {
        case .title:
            return data.sorted { $0.title ?? "" < $1.title ?? "" }
        case .datetime:
            return data.sorted { $0.datetime ?? Date() > $1.datetime ?? Date() }
        default: return data
        }
    }
    
}

