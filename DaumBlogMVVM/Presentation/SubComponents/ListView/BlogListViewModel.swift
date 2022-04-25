//
//  BlogListViewModel.swift
//  DaumBlogMVVM
//
//  Created by Seonghwan on 2022/02/04.
//

import RxSwift
import RxCocoa
class BlogListViewModel {
    //BlogListView가 FilterView를 헤더로 사용하기 때문에
    //BlogListViewModel에 포함
    let filterViewModel = FilterViewModel()
    
    //MainViewController -> BlogListView
    let blogCellData = PublishSubject<[BlogListCellData]>() //가져올 data
    let cellData: Driver<[BlogListCellData]>
    
    init() {
        self.cellData = blogCellData
            .asDriver(onErrorJustReturn: [])
    }
}
